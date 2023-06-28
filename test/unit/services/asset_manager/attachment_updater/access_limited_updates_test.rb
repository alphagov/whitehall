require "test_helper"

class AssetManager::AttachmentUpdater::AccessLimitedUpdatesTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe AssetManager::AttachmentUpdater::AccessLimitedUpdates do
    let(:updater) { AssetManager::AttachmentUpdater }
    let(:attachment_data) { attachment.attachment_data }
    let(:update_worker) { mock("asset-manager-update-asset-worker") }

    describe "Attachment Data has no assets" do
      around do |test|
        AssetManager.stub_const(:AssetUpdater, update_worker) do
          test.call
        end
      end

      context "when attachment's attachable is access limited and the attachment is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

        before do
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)

          access_limited_object = stub("access-limited-object")
          AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(%w[user-uid])

          attachment_data.stubs(:access_limited?).returns(true)
          attachment_data.stubs(:access_limited_object).returns(access_limited_object)
        end

        it "updates the access limited state of the asset" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.asset_manager_path, { "access_limited" => %w[user-uid] })

          updater.call(attachment_data, access_limited: true)
        end
      end

      context "when attachment's attachable is access limited and the attachment is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

        before do
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)

          access_limited_object = stub("access-limited-object")
          AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(%w[user-uid])

          attachment_data.stubs(:access_limited?).returns(true)
          attachment_data.stubs(:access_limited_object).returns(access_limited_object)
        end

        it "updates the access limited state of the asset and it's thumbnail" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.asset_manager_path, { "access_limited" => %w[user-uid] })
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.thumbnail.asset_manager_path, { "access_limited" => %w[user-uid] })

          updater.call(attachment_data, access_limited: true)
        end
      end

      context "when attachment's attachable is not access limited and the attachment is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

        before do
          attachment_data.stubs(:access_limited?).returns(false)
        end

        it "updates the asset to have an empty access_limited array" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.asset_manager_path, { "access_limited" => [] })

          updater.call(attachment_data, access_limited: true)
        end
      end

      context "when attachment's attachable is not access limited and the attachment is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

        before do
          attachment_data.stubs(:access_limited?).returns(false)
        end

        it "updates the asset to have an empty access_limited array" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.asset_manager_path, { "access_limited" => [] })
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.thumbnail.asset_manager_path, { "access_limited" => [] })

          updater.call(attachment_data, access_limited: true)
        end
      end
    end

    describe "Attachment Data has asset(s)" do
      around do |test|
        AssetManager.stub_const(:AssetUpdater, update_worker) do
          test.call
        end
      end

      context "when attachment's attachable is access limited and the attachment is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }
        let(:asset) { Asset.new(asset_manager_id: "asset_manager_id", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }

        before do
          attachment_data.assets = [asset]
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)

          access_limited_object = stub("access-limited-object")
          AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(%w[user-uid])

          attachment_data.stubs(:access_limited?).returns(true)
          attachment_data.stubs(:access_limited_object).returns(access_limited_object)
        end

        it "updates the access limited state of the asset" do
          update_worker.expects(:call)
                       .with(asset.asset_manager_id, attachment_data, nil, { "access_limited" => %w[user-uid] })

          updater.call(attachment_data, access_limited: true)
        end
      end

      context "when attachment's attachable is access limited and the attachment is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
        let(:pdf_asset) { Asset.new(asset_manager_id: "asset_manager_id_1", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }
        let(:pdf_thumbnail_asset) { Asset.new(asset_manager_id: "asset_manager_id_2", attachment_data_id: attachment_data.id, variant: Asset.variants[:thumbnail]) }

        before do
          attachment_data.assets = [pdf_asset, pdf_thumbnail_asset]
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)

          access_limited_object = stub("access-limited-object")
          AssetManagerAccessLimitation.stubs(:for).with(access_limited_object).returns(%w[user-uid])

          attachment_data.stubs(:access_limited?).returns(true)
          attachment_data.stubs(:access_limited_object).returns(access_limited_object)
        end

        it "updates the access limited state of the asset and its thumbnail" do
          update_worker.expects(:call)
                       .with(pdf_asset.asset_manager_id, attachment_data, nil, { "access_limited" => %w[user-uid] })
          update_worker.expects(:call)
                       .with(pdf_thumbnail_asset.asset_manager_id, attachment_data, nil, { "access_limited" => %w[user-uid] })

          updater.call(attachment_data, access_limited: true)
        end
      end

      context "when attachment's attachable is not access limited and the attachment is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }
        let(:asset) { Asset.new(asset_manager_id: "asset_manager_id", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }

        before do
          attachment_data.assets = [asset]
          attachment_data.stubs(:access_limited?).returns(false)
        end

        it "updates the asset to have an empty access_limited array" do
          update_worker.expects(:call)
                       .with(asset.asset_manager_id, attachment_data, nil, { "access_limited" => [] })

          updater.call(attachment_data, access_limited: true)
        end
      end

      context "when attachment's attachable is not access limited and the attachment is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
        let(:pdf_asset) { Asset.new(asset_manager_id: "asset_manager_id_1", attachment_data_id: attachment_data.id, variant: Asset.variants[:original]) }
        let(:pdf_thumbnail_asset) { Asset.new(asset_manager_id: "asset_manager_id_2", attachment_data_id: attachment_data.id, variant: Asset.variants[:thumbnail]) }

        before do
          attachment_data.assets = [pdf_asset, pdf_thumbnail_asset]
          attachment_data.stubs(:access_limited?).returns(false)
        end

        it "updates the asset to have an empty access_limited array" do
          update_worker.expects(:call)
                       .with(pdf_asset.asset_manager_id, attachment_data, nil, { "access_limited" => [] })
          update_worker.expects(:call)
                       .with(pdf_thumbnail_asset.asset_manager_id, attachment_data, nil, { "access_limited" => [] })

          updater.call(attachment_data, access_limited: true)
        end
      end
    end
  end
end
