require "test_helper"

class AssetManager::AttachmentUpdater::ReplacementIdUpdatesTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentUpdater::ReplacementIdUpdates do
    let(:updater) { AssetManager::AttachmentUpdater }
    let(:update_worker) { mock("asset-manager-update-asset-worker") }

    around do |test|
      AssetManager.stub_const(:AssetUpdater, update_worker) do
        test.call
      end
    end

    describe "Attachment Data has no assets" do
      context "when attachment data is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:sample_docx) { File.open(fixture_path.join("sample.docx")) }
        let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
        let(:replacement) { AttachmentData.create!(file: sample_docx) }
        let(:key) { "replacement_legacy_url_path" }
        let(:attributes) { { key => replacement.file.asset_manager_path } }

        it "updates replacement ID of corresponding asset" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment_data.file.asset_manager_path, attributes)

          updater.call(attachment_data, replacement_id: true)
        end
      end

      context "when attachment does not have a replacement" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment_data) { AttachmentData.create!(file: sample_rtf) }

        it "does not update asset manager" do
          update_worker.expects(:call).never

          updater.call(attachment_data, replacement_id: true)
        end
      end

      context "when attachment data is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:whitepaper_pdf) { File.open(fixture_path.join("whitepaper.pdf")) }
        let(:attachment_data) { AttachmentData.create!(file: simple_pdf, replaced_by: replacement) }
        let(:replacement) { AttachmentData.create!(file: whitepaper_pdf) }
        let(:key) { "replacement_legacy_url_path" }
        let(:replacement_url_path) { replacement.file.asset_manager_path }
        let(:attributes) { { key => replacement_url_path } }
        let(:replacement_thumbnail_url_path) { replacement.file.thumbnail.asset_manager_path }
        let(:thumbnail_attributes) { { key => replacement_thumbnail_url_path } }

        it "updates replacement ID of asset for attachment & its thumbnail" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment_data.file.asset_manager_path, attributes)
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment_data.file.thumbnail.asset_manager_path, thumbnail_attributes)

          updater.call(attachment_data, replacement_id: true)
        end

        context "but replacement is not a PDF" do
          let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
          let(:replacement) { AttachmentData.create!(file: sample_rtf) }
          let(:thumbnail_attributes) { { key => replacement_url_path } }

          it "updates replacement ID of asset for attachment & its thumbnail" do
            update_worker.expects(:call)
                         .with(nil, attachment_data, attachment_data.file.asset_manager_path, attributes)
            update_worker.expects(:call)
                         .with(nil, attachment_data, attachment_data.file.thumbnail.asset_manager_path, thumbnail_attributes)

            updater.call(attachment_data, replacement_id: true)
          end
        end
      end

      context "when attachment is not synced with asset manager" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:sample_docx) { File.open(fixture_path.join("sample.docx")) }
        let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
        let(:replacement) { AttachmentData.create!(file: sample_docx) }

        before do
          update_worker.expects(:call)
                       .raises(AssetManager::ServiceHelper::AssetNotFound.new("asset not found"))
        end

        it "raises a AssetNotFound error" do
          assert_raises(AssetManager::ServiceHelper::AssetNotFound) do
            updater.call(attachment_data, replacement_id: true)
          end
        end
      end
    end

    describe "Attachment Data has asset(s)" do
      context "when attachment data being updated is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:sample_docx) { File.open(fixture_path.join("sample.docx")) }
        let(:replacement) { AttachmentData.create!(file: sample_docx) }
        let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
        let(:attributes) { { "replacement_id" => replacement_original_asset.asset_manager_id } }
        let(:original_asset) { Asset.new(asset_manager_id: "asset_manager_id", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }
        let(:replacement_original_asset) { Asset.new(asset_manager_id: "replacement_asset_manager_id", attachment_data_id: replacement.id, variant: Asset.variants[:original]) }

        it "updates replacement ID of corresponding asset" do
          attachment_data.assets = [original_asset]
          replacement.assets = [replacement_original_asset]

          update_worker.expects(:call)
                       .with(original_asset.asset_manager_id, attachment_data, nil, attributes)

          updater.call(attachment_data, replacement_id: true)
        end
      end

      context "when attachment does not have a replacement" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment_data) { AttachmentData.create!(file: sample_rtf) }

        it "does not update asset manager" do
          update_worker.expects(:call).never

          updater.call(attachment_data, replacement_id: true)
        end
      end

      context "when attachment data being updated is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:whitepaper_pdf) { File.open(fixture_path.join("whitepaper.pdf")) }
        let(:attachment_data) { AttachmentData.create!(file: simple_pdf, replaced_by: replacement) }
        let(:replacement) { AttachmentData.create!(file: whitepaper_pdf) }
        let(:attributes) { { "replacement_id" => replacement_original_asset.asset_manager_id } }
        let(:thumbnail_attributes) { { "replacement_id" => replacement_thumbnail_asset.asset_manager_id } }
        let(:original_asset) { Asset.new(asset_manager_id: "asset_manager_id_1", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }
        let(:thumbnail_asset) { Asset.new(asset_manager_id: "asset_manager_id_2", attachment_data_id: attachment_data.id, variant: Asset.variants[:thumbnail]) }
        let(:replacement_original_asset) { Asset.new(asset_manager_id: "replacement_asset_manager_id_1", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }
        let(:replacement_thumbnail_asset) { Asset.new(asset_manager_id: "replacement_asset_manager_id_2", attachment_data_id: attachment_data.id, variant: Asset.variants[:thumbnail]) }

        it "and replacement is a pdf - updates replacement ID of asset for attachment & its thumbnail" do
          attachment_data.assets = [original_asset, thumbnail_asset]
          replacement.assets = [replacement_original_asset, replacement_thumbnail_asset]

          update_worker.expects(:call)
                       .with(original_asset.asset_manager_id, attachment_data, nil, attributes)
          update_worker.expects(:call)
                       .with(thumbnail_asset.asset_manager_id, attachment_data, nil, thumbnail_attributes)

          updater.call(attachment_data, replacement_id: true)
        end

        context "but replacement is not a PDF" do
          let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
          let(:replacement) { AttachmentData.create!(file: sample_rtf) }

          it "updates replacement ID of asset for attachment & its thumbnail" do
            attachment_data.assets = [original_asset, thumbnail_asset]
            replacement.assets = [replacement_original_asset]

            update_worker.expects(:call)
                         .with(original_asset.asset_manager_id, attachment_data, nil, attributes)
            update_worker.expects(:call)
                         .with(thumbnail_asset.asset_manager_id, attachment_data, nil, attributes)

            updater.call(attachment_data, replacement_id: true)
          end
        end
      end

      context "when attachment is not synced with asset manager" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:sample_docx) { File.open(fixture_path.join("sample.docx")) }
        let(:attachment_data) { AttachmentData.create!(file: sample_rtf, replaced_by: replacement) }
        let(:replacement) { AttachmentData.create!(file: sample_docx) }

        before do
          update_worker.expects(:call)
                       .raises(AssetManager::ServiceHelper::AssetNotFound.new("asset not found"))
        end

        it "raises a AssetNotFound error" do
          assert_raises(AssetManager::ServiceHelper::AssetNotFound) do
            updater.call(attachment_data, replacement_id: true)
          end
        end
      end
    end
  end
end
