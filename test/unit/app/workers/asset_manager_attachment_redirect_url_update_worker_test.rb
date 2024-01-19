require "test_helper"

class AssetManagerAttachmentRedirectUrlUpdateWorkerTest < ActiveSupport::TestCase
  test "it updates redirect url for all assets" do
    edition = create(:unpublished_edition)
    attachment = create(:file_attachment, attachable: edition)

    expected_attribute_hash = {
      "redirect_url" => edition.unpublishing.document_url,
    }

    attachment.attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
    end

    AssetManagerAttachmentRedirectUrlUpdateWorker.new.perform(attachment.attachment_data.id)
  end
end
