require 'test_helper'
require 'whitehall/asset_manager_storage'

class Whitehall::AssetManagerStorageTest < ActiveSupport::TestCase
  class AssetManagerUploader < CarrierWave::Uploader::Base
    storage :asset_manager
  end

  setup do
    @file = Tempfile.new('asset')
    @uploader = AssetManagerUploader.new
    FileUtils.mkdir_p(Whitehall.asset_manager_tmp_dir)
  end

  teardown do
    FileUtils.remove_dir(Whitehall.asset_manager_tmp_dir, true)
  end

  test "creates a sidekiq job using the location of the file in the asset manager tmp directory" do
    AssetManagerCreateWhitehallAssetWorker.expects(:perform_async).with do |actual_path, _|
      uploaded_file_name = File.basename(@file.path)
      expected_path = %r{#{Whitehall.asset_manager_tmp_dir}/[a-z0-9\-]+/#{uploaded_file_name}}
      actual_path =~ expected_path
    end

    @uploader.store!(@file)
  end

  test 'creates a sidekiq job and sets the legacy url path to the location that it would have been stored on disk' do
    @uploader.store_dir = 'store-dir'

    expected_filename = File.basename(@file.path)
    expected_path = File.join('/government/uploads/store-dir', expected_filename)
    AssetManagerCreateWhitehallAssetWorker.expects(:perform_async).with(anything, expected_path)

    @uploader.store!(@file)
  end

  test 'returns the sanitized file' do
    AssetManagerCreateWhitehallAssetWorker.stubs(:perform_async)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    file = CarrierWave::SanitizedFile.new(@file)
    assert_equal file, storage.store!(file)
  end

  test 'instantiates an asset manager file with the location of the file on disk' do
    storage = Whitehall::AssetManagerStorage.new(@uploader)
    @uploader.stubs(:store_path).with('identifier').returns('asset-path')

    Whitehall::AssetManagerStorage::File.expects(:new).with('asset-path')

    storage.retrieve!('identifier')
  end

  test 'returns an asset manager file' do
    file = stub(:asset_manager_file)
    Whitehall::AssetManagerStorage::File.stubs(:new).returns(file)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    assert_equal file, storage.retrieve!('identifier')
  end
end

class Whitehall::AssetManagerStorage::FileTest < ActiveSupport::TestCase
  test 'queues the call to delete the asset from asset manager' do
    file = Whitehall::AssetManagerStorage::File.new('path/to/asset.png')

    AssetManagerDeleteAssetWorker.expects(:perform_async).with('/government/uploads/path/to/asset.png')

    file.delete
  end
end
