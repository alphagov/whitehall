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

  test 'store! returns an asset manager file' do
    AssetManagerCreateWhitehallAssetWorker.stubs(:perform_async)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    file = CarrierWave::SanitizedFile.new(@file)

    assert_equal Whitehall::AssetManagerStorage::File, storage.store!(file).class
  end

  test 'instantiates an asset manager file with the location of the file on disk' do
    storage = Whitehall::AssetManagerStorage.new(@uploader)
    @uploader.stubs(:store_path).with('identifier').returns('asset-path')

    Whitehall::AssetManagerStorage::File.expects(:new).with('asset-path')

    storage.retrieve!('identifier')
  end

  test 'retrieve! returns an asset manager file' do
    file = stub(:asset_manager_file)
    Whitehall::AssetManagerStorage::File.stubs(:new).returns(file)

    storage = Whitehall::AssetManagerStorage.new(@uploader)
    assert_equal file, storage.retrieve!('identifier')
  end
end

class Whitehall::AssetManagerStorage::FileTest < ActiveSupport::TestCase
  setup do
    asset_path = 'path/to/asset.png'
    @asset_url_path = "/government/uploads/#{asset_path}"
    @file = Whitehall::AssetManagerStorage::File.new(asset_path)
  end

  test 'queues the call to delete the asset from asset manager' do
    AssetManagerDeleteAssetWorker.expects(:perform_async).with(@asset_url_path)

    @file.delete
  end

  test 'constructs the url of the file using the public asset host and legacy url path' do
    Plek.stubs(:new).returns(stub('plek', public_asset_host: 'http://assets-host'))

    expected_asset_url = URI.join('http://assets-host', @asset_url_path).to_s

    assert_equal expected_asset_url, @file.url
  end

  test 'returns the legacy filename as the path' do
    assert_equal @asset_url_path, @file.path
  end

  test '#content_type returns the first element of the content type array' do
    assert_equal 'image/png', @file.content_type
  end

  test 'when the legacy_url_path contains non-ascii characters it percent-encodes' do
    asset_path = 'path/to/ässet.png'
    file = Whitehall::AssetManagerStorage::File.new(asset_path)

    Plek.stubs(:new).returns(stub('plek', public_asset_host: 'http://assets-host'))

    assert_equal 'http://assets-host/government/uploads/path/to/%C3%A4sset.png', file.url
  end
end
