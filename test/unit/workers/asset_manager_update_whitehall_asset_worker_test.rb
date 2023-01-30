require "test_helper"

class AssetManagerUpdateWhitehallAssetWorkerTest < ActiveSupport::TestCase
  @auth_bypass_id_attributes = { auth_bypass_ids: [SecureRandom.uuid] }

  def expected_legacy_url(data_type, data_id, file_name)
    "/government/uploads/system/uploads/#{data_type}/file/#{data_id}/#{file_name}"
  end

  test "updates a file attachment" do
    attachment_data = FactoryBot.create(:attachment_data, file: File.open(Rails.root.join("test/fixtures/sample.csv")))
    expected_legacy_url_path = expected_legacy_url("attachment_data", attachment_data.id, "sample.csv")

    AssetManager::AssetUpdater.expects(:call).with(attachment_data, expected_legacy_url_path, @auth_bypass_id_attributes)

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end

  test "updates a PDF attachment and its preview thumbnail" do
    attachment_data = FactoryBot.create(:attachment_data)
    expected_legacy_url_path = expected_legacy_url("attachment_data", attachment_data.id, "greenpaper.pdf")
    expected_legacy_url_thumbnail_path = expected_legacy_url("attachment_data", attachment_data.id, "thumbnail_greenpaper.pdf.png")

    AssetManager::AssetUpdater.expects(:call).with(attachment_data, expected_legacy_url_path, @auth_bypass_id_attributes)
    AssetManager::AssetUpdater.expects(:call).with(attachment_data, expected_legacy_url_thumbnail_path, @auth_bypass_id_attributes)

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end

  test "updates an image and its resized thumbnail versions" do
    image_data = FactoryBot.create(:image_data)
    %w[
      minister-of-funk.960x640.jpg
      s960_minister-of-funk.960x640.jpg
      s712_minister-of-funk.960x640.jpg
      s630_minister-of-funk.960x640.jpg
      s465_minister-of-funk.960x640.jpg
      s300_minister-of-funk.960x640.jpg
      s216_minister-of-funk.960x640.jpg
    ].each do |filename|
      path = expected_legacy_url("image_data", image_data.id, filename)
      AssetManager::AssetUpdater.expects(:call).with(image_data, path, @auth_bypass_id_attributes).once
    end

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "ImageData", image_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end

  test "updates a consultation response form" do
    response_form = FactoryBot.create(:consultation_response_form)
    form_data = response_form.consultation_response_form_data
    expected_legacy_url_path = expected_legacy_url("consultation_response_form_data", form_data.id, "two-pages.pdf")
    AssetManager::AssetUpdater.expects(:call).with(form_data, expected_legacy_url_path, @auth_bypass_id_attributes)

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "ConsultationResponseFormData", form_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end

  test "ignores missing assets in Asset Manager" do
    attachment_data = FactoryBot.create(:attachment_data)

    expected_error = AssetManager::ServiceHelper::AssetNotFound.new(attachment_data.file.asset_manager_path)
    AssetManager::AssetUpdater.expects(:call).once.raises(expected_error)
    Logger.any_instance.stubs(:error).once # suppress log output

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end

  test "ignores assets that have been deleted in Asset Manager" do
    attachment_data = FactoryBot.create(:attachment_data)

    expected_error = AssetManager::AssetUpdater::AssetAlreadyDeleted.new(attachment_data.id, attachment_data.file.asset_manager_path)
    AssetManager::AssetUpdater.expects(:call).once.raises(expected_error)
    Logger.any_instance.stubs(:error).once # suppress log output

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end

  test "ignores assets that have been deleted in Whitehall" do
    attachment_data = FactoryBot.create(:attachment_data)
    attachment_data_id = attachment_data.id

    Logger.any_instance.stubs(:error).once # suppress log output
    attachment_data.destroy!

    AssetManagerUpdateWhitehallAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data_id, @auth_bypass_id_attributes)
    AssetManagerUpdateWhitehallAssetWorker.drain
  end
end
