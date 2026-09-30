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
      Services.asset_manager.stubs(:restore_asset)
      Services.asset_manager.stubs(:update_asset)
      AttachmentData.stubs(:find_by).returns(stub(attachments: []))
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

    let(:unpublished_edition) do
      stub(
        post_published_state?: true,
        unpublished?: true,
        unpublishing: stub(alternative_url: "https://www.gov.uk/example"),
        public_url: "https://www.gov.uk/unpublished-edition",
      )
    end
    let(:unpublished_edition_without_alternative_url) do
      stub(
        post_published_state?: true,
        unpublished?: true,
        unpublishing: stub(alternative_url: nil),
        public_url: "https://www.gov.uk/unpublished-edition",
      )
    end
    let(:published_edition) { stub(post_published_state?: true, unpublished?: false) }
    let(:draft_edition) { stub(post_published_state?: false) }

    def stub_attachables(ad_id, *attachables)
      attachment_data = stub(attachments: attachables.map { |attachable| stub(attachable:) })
      AttachmentData.stubs(:find_by).with(id: ad_id).returns(attachment_data)
    end

    it "summarizes the CSV file" do
      out, _err = capture_io { task.invoke(csv_file.path) }
      assert_includes(out, "Parsed CSV. First row: #<struct CherryPickedRowData asset_manager_id=\"5a7b9cbe40f0b645ba3c571d\", ad_id=276771, redirect_url=\"https://www.gov.uk/government/publications/free-schools-site-management\">\n")
    end

    it "restores every asset" do
      Services.asset_manager.expects(:restore_asset).with("5a7b9cbe40f0b645ba3c571d")
      Services.asset_manager.expects(:restore_asset).with("6a7b9cbe40f0b645ba3c571d")

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "restores the asset before updating its redirect_url" do
      stub_attachables(276_771, unpublished_edition)

      restore = sequence("restore")
      Services.asset_manager.expects(:restore_asset).with("5a7b9cbe40f0b645ba3c571d").in_sequence(restore)
      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: "https://www.gov.uk/example" }).in_sequence(restore)

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "ignores the redirect_url in the CSV, which may be out of sync with Whitehall" do
      stub_attachables(276_771, published_edition)

      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: nil })

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url to the Unpublishing's alternative_url if the latest live edition is unpublished" do
      stub_attachables(276_771, unpublished_edition)

      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: "https://www.gov.uk/example" })

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "sets the redirect_url to the Edition's public_url if the latest live edition is unpublished with no alternative_url" do
      stub_attachables(276_771, unpublished_edition_without_alternative_url)

      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: "https://www.gov.uk/unpublished-edition" })

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "ignores drafts when finding the latest live edition" do
      stub_attachables(276_771, unpublished_edition, draft_edition)

      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: "https://www.gov.uk/example" })

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "clears the redirect_url if the latest live edition is not unpublished" do
      stub_attachables(276_771, unpublished_edition, published_edition)

      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: nil })

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "clears the redirect_url if there is no live edition" do
      stub_attachables(276_771, draft_edition)

      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", { redirect_url: nil })

      # Swallow output to avoid messy unit test run
      _out, _err = capture_io { task.invoke(csv_file.path) }
    end

    it "skips the asset, and outputs an error message, if the AttachmentData cannot be found" do
      AttachmentData.stubs(:find_by).with(id: 276_771).returns(nil)

      Services.asset_manager.expects(:restore_asset).with("5a7b9cbe40f0b645ba3c571d").never
      Services.asset_manager.expects(:update_asset).with("5a7b9cbe40f0b645ba3c571d", anything).never

      _out, err = capture_io { task.invoke(csv_file.path) }
      assert_includes(err, "Skipping asset 5a7b9cbe40f0b645ba3c571d: AttachmentData 276771 not found")
    end
  end
end
