require "test_helper"

class AssetManagerAttachmentRedirectUrlUpdateJobTest < ActiveSupport::TestCase
  test "it updates redirect url for all assets" do
    edition = create(:unpublished_edition)
    attachment = create(:file_attachment, attachable: edition)

    expected_attribute_hash = {
      "redirect_url" => edition.unpublishing.document_url,
    }

    attachment.attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
    end

    AssetManagerAttachmentRedirectUrlUpdateJob.new.perform(attachment.attachment_data.id)
  end

  test "it updates redirect url when attachment_data is marked deleted and redirect url is present" do
    edition = create(:unpublished_edition)
    attachment = create(:file_attachment, attachable: edition)

    AttachmentData.any_instance.stubs(:deleted?).returns(true)

    expected_attribute_hash = {
      "redirect_url" => edition.unpublishing.document_url,
    }

    attachment.attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash)
    end

    AssetManagerAttachmentRedirectUrlUpdateJob.new.perform(attachment.attachment_data.id)
  end

  test "it does not update redirect url when attachment_data is marked deleted and redirect url is nil" do
    edition = create(:published_edition)
    attachment = create(:file_attachment, attachable: edition)

    AttachmentData.any_instance.stubs(:deleted?).returns(true)

    expected_attribute_hash = {
      "redirect_url" => nil,
    }

    attachment.attachment_data.assets.each do |asset|
      AssetManager::AssetUpdater.expects(:call).with(asset.asset_manager_id, expected_attribute_hash).never
    end

    AssetManagerAttachmentRedirectUrlUpdateJob.new.perform(attachment.attachment_data.id)
  end
end
