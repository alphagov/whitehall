require "test_helper"

class AssetManager::AttachmentUpdater::LinkHeaderUpdatesTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers
  include PublicDocumentRoutesHelper

  describe AssetManager::AttachmentUpdater::LinkHeaderUpdates do
    let(:updater) { AssetManager::AttachmentUpdater }
    let(:attachment_data) { attachment.attachment_data }
    let(:edition) { FactoryBot.create(:published_edition) }
    let(:parent_document_url) { edition.public_url(locale: :en) }
    let(:update_worker) { mock("asset-manager-update-worker") }

    around do |test|
      AssetManager.stub_const(:AssetUpdater, update_worker) do
        test.call
      end
    end

    context "when attachment doesn't belong to an edition" do
      let(:attachment) { FactoryBot.create(:file_attachment) }

      it "does not update draft status of any assets" do
        update_worker.expects(:call).never

        updater.call(attachment_data, link_header: true)
      end
    end

    context "when attachment is not a PDF" do
      let(:sample_rtf) { File.open(fixture_path.join("sample.rtf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: sample_rtf, attachable: edition) }

      it "sets parent_document_url of corresponding asset" do
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.asset_manager_path, { "parent_document_url" => parent_document_url })

        updater.call(attachment_data, link_header: true)
      end
    end

    context "when attachment is a PDF" do
      let(:simple_pdf) { File.open(fixture_path.join("simple.pdf")) }
      let(:attachment) { FactoryBot.create(:file_attachment, file: simple_pdf, attachable: edition) }

      it "sets parent_document_url for attachment & its thumbnail" do
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.asset_manager_path, { "parent_document_url" => parent_document_url })
        update_worker.expects(:call)
          .with(attachment_data, attachment.file.thumbnail.asset_manager_path, { "parent_document_url" => parent_document_url })

        updater.call(attachment_data, link_header: true)
      end
    end
  end
end
