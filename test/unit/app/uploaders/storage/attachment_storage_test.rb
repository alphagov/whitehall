require "test_helper"

class AttachmentStorageTest < ActiveSupport::TestCase
  setup do
    @file = Tempfile.new("asset")
    FileUtils.mkdir_p(Whitehall.asset_manager_tmp_dir)
  end

  teardown do
    FileUtils.remove_dir(Whitehall.asset_manager_tmp_dir, true)
  end

  test "store! stores the file in asset manager and returns a asset manager file object" do
    edition = create(:draft_news_article, :with_file_attachment, auth_bypass_id: "test-bypass-id")
    attachment = edition.attachments.first

    # Something has to set the transient "attachable" attribute on the data model for the uploader to work, in its current design
    attachment.attachment_data.attachable = edition
    uploader = AttachmentUploader.new(attachment.attachment_data)

    storage = Storage::AttachmentStorage.new(uploader)
    file = CarrierWave::SanitizedFile.new(@file)

    AssetManagerCreateAttachmentAssetWorker.expects(:perform_async).with do |actual_path, asset_params, draft, attachable_model_class, attachable_id, auth_bypass_ids|
      uploaded_file_name = File.basename(@file.path)
      expected_path = %r{#{Whitehall.asset_manager_tmp_dir}/[a-z0-9-]+/#{uploaded_file_name}}

      expected_asset_params = { assetable_id: uploader.model.id, asset_variant: Asset.variants[:original], assetable_type: uploader.model.class.to_s }.deep_stringify_keys

      actual_path =~ expected_path && asset_params == expected_asset_params && draft == true && attachable_model_class == edition.class.to_s && attachable_id == edition.id && auth_bypass_ids == [edition.auth_bypass_id]
    end

    result = storage.store!(file)

    assert result.filename.include? file.basename
  end

  test "retrieve! returns an asset manager file with the location of the file on disk" do
    edition = create(:draft_news_article, :with_file_attachment)
    attachment = edition.attachments.first
    filename = "identifier.jpg"
    uploader = AttachmentUploader.new(attachment.attachment_data)
    storage = Storage::AttachmentStorage.new(uploader)

    file = storage.retrieve!(filename)

    assert_equal file.path, uploader.store_path(filename)
  end
end
