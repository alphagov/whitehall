require "test_helper"

class AssetManagerUpdateAssetWorkerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:auth_bypass_id_attributes) do
    { "auth_bypass_ids" => [SecureRandom.uuid] }
  end
  let(:attachment_data) { FactoryBot.create(:attachment_data, attachable: create(:draft_publication)) }

  test "updates an attachment and its variant" do
    AssetManager::AssetUpdater.expects(:call).with("asset_manager_id_original", auth_bypass_id_attributes)
    AssetManager::AssetUpdater.expects(:call).with("asset_manager_id_thumbnail", auth_bypass_id_attributes)

    AssetManagerUpdateAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data.id, auth_bypass_id_attributes)
    AssetManagerUpdateAssetWorker.drain
  end

  test "ignores missing assets in Asset Manager" do
    expected_error = AssetManager::ServiceHelper::AssetNotFound.new("asset_manager_id_original")
    AssetManager::AssetUpdater.expects(:call).once.raises(expected_error)
    Logger.any_instance.stubs(:error).with(includes(expected_error.message)).once

    AssetManagerUpdateAssetWorker.perform_async_in_queue("asset_manager_updater", "AttachmentData", attachment_data.id, auth_bypass_id_attributes)
    AssetManagerUpdateAssetWorker.drain
  end

  test "updates an image and its resized versions" do
    image_data = FactoryBot.create(:image_data)
    %w[
      asset_manager_id_original
      asset_manager_id_s960
      asset_manager_id_s712
      asset_manager_id_s630
      asset_manager_id_s465
      asset_manager_id_s300
      asset_manager_id_s216
    ].each do |asset_manager_id|
      AssetManager::AssetUpdater.expects(:call).with(asset_manager_id, @auth_bypass_id_attributes).once
    end

    AssetManagerUpdateAssetWorker.perform_async_in_queue("asset_manager_id_original", "ImageData", image_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateAssetWorker.drain
  end

  test "updates the consultation response form variant" do
    response_form = FactoryBot.create(:consultation_response_form)
    form_data = response_form.consultation_response_form_data

    AssetManager::AssetUpdater.expects(:call).with("asset_manager_id_original", @auth_bypass_id_attributes)

    AssetManagerUpdateAssetWorker.perform_async_in_queue("asset_manager_updater", "ConsultationResponseFormData", form_data.id, @auth_bypass_id_attributes)
    AssetManagerUpdateAssetWorker.drain
  end
end
