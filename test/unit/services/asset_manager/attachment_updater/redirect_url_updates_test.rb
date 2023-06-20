require "test_helper"

class AssetManager::AttachmentUpdater::RedirectUrlUpdatesTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  describe AssetManager::AttachmentUpdater::RedirectUrlUpdates do
    let(:updater) { AssetManager::AttachmentUpdater }
    let(:attachment_data) { attachment.attachment_data }
    let(:unpublished_edition) { FactoryBot.create(:unpublished_edition) }
    let(:redirect_url) { unpublished_edition.public_url }
    let(:unpublished) { true }
    let(:update_worker) { mock("asset-manager-update-asset-worker") }

    around do |test|
      AssetManager.stub_const(:AssetUpdater, update_worker) do
        test.call
      end
    end

    describe "Attachment Data has no assets" do
      context "when attachment is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }

        before do
          attachment_data.stubs(:unpublished?).returns(unpublished)
          attachment_data.stubs(:present_at_unpublish?).returns(true)
          attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)
        end

        it "updates redirect URL of corresponding asset" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.asset_manager_path, { "redirect_url" => redirect_url })

          updater.call(attachment_data, redirect_url: true)
        end
      end

      context "when attachment is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }

        before do
          attachment_data.stubs(:unpublished?).returns(unpublished)
          attachment_data.stubs(:present_at_unpublish?).returns(true)
          attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)
        end

        it "updates redirect URL of asset for attachment & its thumbnail" do
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.asset_manager_path, { "redirect_url" => redirect_url })
          update_worker.expects(:call)
                       .with(nil, attachment_data, attachment.file.thumbnail.asset_manager_path, { "redirect_url" => redirect_url })

          updater.call(attachment_data, redirect_url: true)
        end

        context "and attachment is not unpublished" do
          let(:unpublished) { false }
          let(:unpublished_edition) { nil }

          it "resets redirect URL of asset for attachment & its thumbnail" do
            update_worker.expects(:call)
                         .with(nil, attachment_data, attachment.file.asset_manager_path, { "redirect_url" => nil })
            update_worker.expects(:call)
                         .with(nil, attachment_data, attachment.file.thumbnail.asset_manager_path, { "redirect_url" => nil })

            updater.call(attachment_data, redirect_url: true)
          end
        end
      end
    end

    describe "Attachment Data has asset(s)" do
      context "when attachment is not a PDF" do
        let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf) }
        let(:asset) { Asset.new(asset_manager_id: "asset_manager_id", attachment_data_id: attachment_data.id, version: Asset.versions[:original]) }

        before do
          attachment_data.assets = [asset]
          attachment_data.stubs(:unpublished?).returns(unpublished)
          attachment_data.stubs(:present_at_unpublish?).returns(true)
          attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)
        end

        it "updates redirect URL of corresponding asset" do
          update_worker.expects(:call)
                       .with(asset.asset_manager_id, attachment_data, nil, { "redirect_url" => redirect_url })

          updater.call(attachment_data, redirect_url: true)
        end
      end

      context "when attachment is a PDF" do
        let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
        let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf) }
        let(:pdf_asset) { Asset.new(asset_manager_id: "asset_manager_id_1", attachment_data_id: attachment_data.id, version: Asset.versions[:original]) }
        let(:pdf_thumbnail_asset) { Asset.new(asset_manager_id: "asset_manager_id_2", attachment_data_id: attachment_data.id, version: Asset.versions[:thumbnail]) }

        before do
          attachment_data.assets = [pdf_asset, pdf_thumbnail_asset]
          attachment_data.stubs(:unpublished?).returns(unpublished)
          attachment_data.stubs(:present_at_unpublish?).returns(true)
          attachment_data.stubs(:unpublished_edition).returns(unpublished_edition)
          AttachmentData.stubs(:find_by).with(id: attachment_data.id).returns(attachment_data)
        end

        it "updates redirect URL of asset for attachment & its thumbnail" do
          update_worker.expects(:call)
                       .with(pdf_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => redirect_url })
          update_worker.expects(:call)
                       .with(pdf_thumbnail_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => redirect_url })

          updater.call(attachment_data, redirect_url: true)
        end

        context "and attachment is not unpublished" do
          let(:unpublished) { false }
          let(:unpublished_edition) { nil }

          it "resets redirect URL of asset for attachment & its thumbnail" do
            update_worker.expects(:call)
                         .with(pdf_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => nil })
            update_worker.expects(:call)
                         .with(pdf_thumbnail_asset.asset_manager_id, attachment_data, nil, { "redirect_url" => nil })

            updater.call(attachment_data, redirect_url: true)
          end
        end
      end
    end
  end
end
