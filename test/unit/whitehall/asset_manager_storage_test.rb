require 'test_helper'
require 'whitehall/asset_manager_storage'

class Whitehall::AssetManagerStorageTest < ActiveSupport::TestCase
  class AssetManagerUploader < CarrierWave::Uploader::Base
    storage :asset_manager
  end

  setup do
    @file = Tempfile.new('asset')
    @uploader = AssetManagerUploader.new
  end

  test 'creates a whitehall asset using the file passed to the uploader' do
    Services.asset_manager.expects(:create_whitehall_asset).with(&same_content_as(@file))

    @uploader.store!(@file)
  end

  test 'creates a whitehall asset using an instance of a file object' do
    Services.asset_manager.expects(:create_whitehall_asset).with do |args|
      args[:file].is_a?(File)
    end

    @uploader.store!(@file)
  end

  test 'creates a whitehall asset and sets the legacy url path to the location that it would have been stored on disk' do
    @uploader.store_dir = 'store-dir'

    expected_filename = File.basename(@file.path)
    expected_path = File.join('/government/uploads/store-dir', expected_filename)
    Services.asset_manager.expects(:create_whitehall_asset).with(has_entry(legacy_url_path: expected_path))

    @uploader.store!(@file)
  end

  test 'returns the sanitized file' do
    Services.asset_manager.stubs(:create_whitehall_asset)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    file = CarrierWave::SanitizedFile.new(@file)
    assert_equal file, storage.store!(file)
  end

  test 'fails fast when trying to retrieve an existing file' do
    storage = Whitehall::AssetManagerStorage.new(@uploader)
    assert_raises RuntimeError do
      storage.retrieve!('identifier')
    end
  end

private

  def same_content_as(file)
    -> (args) {
      args[:file].read == file.read
    }
  end
end
