require "test_helper"
require "rake"

class PatchAssetsTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  teardown do
    task.reenable
  end

  let(:task) { Rake::Task["data_hygiene:patch_assets"] }

  context "no CSV file provided" do
    it "outputs an error message" do
      _out, err = capture_io { task.invoke }
      assert_includes(err, "CSV file arg missing")
    end
  end

  context "CSV file does not exist" do
    it "outputs an error message" do
      _out, err = capture_io { task.invoke("non_existent_file.csv") }
      assert_includes(err, "CSV file not found: non_existent_file.csv")
    end
  end

  context "CSV file exists" do
    before do
      AssetManagerRestoreAssetJob.stubs(:perform_async)
    end

    let(:csv_file) do
      file = Tempfile.new(%w[patch_assets .csv])
      file.write(csv_data)
      file.close
      file
    end

    after do
      csv_file.unlink
    end

    let(:csv_data) do
      <<~CSV
        ad_id,filename,asset_manager_id,attachment_id,attachment_title,attachment_deleted,attachable_state,attachable_id,attachable_updated_at,deleted_at,draft,replacement_id,redirect_url
        276771,para_7-6_site_fittings.pdf,5a7b9cbe40f0b645ba3c571d,512866,"This attachment has a redirect URL",false,unpublished,306476,2019-09-06 14:57:36.000000 UTC,2019-09-06 14:57:36.569000 UTC,true,,https://www.gov.uk/government/publications/free-schools-site-management
        276772,para_8-6_site_fittings.pdf,6a7b9cbe40f0b645ba3c571d,512866,"This attachment also has a redirect URL",false,unpublished,306476,2019-09-06 14:57:36.000000 UTC,2019-09-06 14:57:36.569000 UTC,true,,https://www.gov.uk/government/publications/free-schools-site-management-test
      CSV
    end

    def attach_asset_to(*attachables, ad_id: 276_771)
      attachment_data = create(:attachment_data, id: ad_id, attachable: attachables.first)
      attachables.each { |attachable| create(:file_attachment, attachable:, attachment_data:) }
    end

    it "summarizes the CSV file" do
      out, _err = capture_io { task.invoke(csv_file.path) }
      assert_includes(out, "Parsed CSV. First row: #<struct CherryPickedRowData asset_manager_id=\"5a7b9cbe40f0b645ba3c571d\", ad_id=276771, redirect_url=\"https://www.gov.uk/government/publications/free-schools-site-management\">\n")
    end

    it "enqueues a restore job for every asset" do
      attach_asset_to(create(:published_publication), ad_id: 276_771)
      attach_asset_to(create(:published_publication), ad_id: 276_772)

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)
      AssetManagerRestoreAssetJob.expects(:perform_async).with("6a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "ignores the redirect_url in the CSV, which may be out of sync with Whitehall" do
      attach_asset_to(create(:published_publication))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url to the Unpublishing's alternative_url if the document is unpublished" do
      attach_asset_to(create(:unpublished_publication_consolidated))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url to the Unpublishing's document_url if the document is unpublished with no alternative_url" do
      unpublished_edition = create(:unpublished_publication)
      attach_asset_to(unpublished_edition)

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", unpublished_edition.unpublishing.document_url)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "ignores drafts when finding the latest live edition" do
      unpublished_edition = create(:unpublished_publication_consolidated)
      attach_asset_to(unpublished_edition, create(:draft_publication, document: unpublished_edition.document))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url from the document's unpublished edition, even if that edition does not reference the asset" do
      superseded_edition = create(:superseded_publication)
      create(:unpublished_publication_consolidated, document: superseded_edition.document)
      attach_asset_to(superseded_edition, create(:rejected_publication, document: superseded_edition.document))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url from an Unpublishing on a rejected edition, as documents unpublished before the `unpublished` state existed may have one" do
      superseded_edition = create(:superseded_publication)
      create(:rejected_publication, document: superseded_edition.document, unpublishing: build(:consolidated_unpublishing))
      attach_asset_to(superseded_edition)

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url if the only edition referencing the asset is a rejected edition with an Unpublishing" do
      attach_asset_to(create(:rejected_publication, unpublishing: build(:consolidated_unpublishing)))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url if the only edition referencing the asset is a submitted edition with an Unpublishing" do
      attach_asset_to(create(:submitted_publication, unpublishing: build(:consolidated_unpublishing)))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "clears the redirect_url if the only edition referencing the asset is a rejected edition without an Unpublishing" do
      attach_asset_to(create(:rejected_publication))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url for an asset attached to a consultation outcome, using the consultation's document" do
      attach_asset_to(create(:consultation_outcome, consultation: create(:unpublished_consultation, unpublishing: build(:consolidated_unpublishing))))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url for an asset attached to a call for evidence outcome, using the call for evidence's document" do
      attach_asset_to(create(:call_for_evidence_outcome, call_for_evidence: create(:unpublished_call_for_evidence, unpublishing: build(:consolidated_unpublishing))))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url for an asset attached to a worldwide organisation page, using the worldwide organisation's document" do
      attach_asset_to(create(:worldwide_organisation_page, edition: create(:unpublished_worldwide_organisation_consolidated)))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", "#{Whitehall.public_root}/government/another/page")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "ignores withdrawals when finding the document's latest Unpublishing" do
      superseded_edition = create(:superseded_publication, unpublishing: build(:withdrawn_unpublishing))
      attach_asset_to(superseded_edition)

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "clears the redirect_url if the document has since been republished, even if an old Unpublishing remains" do
      superseded_edition = create(:superseded_publication, unpublishing: build(:consolidated_unpublishing))
      create(:published_publication, document: superseded_edition.document)
      attach_asset_to(superseded_edition)

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "clears the redirect_url if the document is neither live nor unpublished" do
      attach_asset_to(create(:superseded_publication))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "clears the redirect_url if there is no live edition" do
      attach_asset_to(create(:draft_publication))

      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", nil)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "does not enqueue a restore job, and outputs an error message, if the AttachmentData cannot be found" do
      AssetManagerRestoreAssetJob.expects(:perform_async).with("5a7b9cbe40f0b645ba3c571d", anything).never

      _out, err = capture_io { task.invoke(csv_file.path) }
      assert_includes(err, "Skipping asset 5a7b9cbe40f0b645ba3c571d: AttachmentData 276771 not found")
    end
  end
end
