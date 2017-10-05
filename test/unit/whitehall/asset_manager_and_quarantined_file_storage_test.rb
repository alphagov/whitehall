require 'test_helper'
require 'whitehall/asset_manager_storage'

class Whitehall::AssetManagerAndQuarantinedFileStorageTest < ActiveSupport::TestCase
  setup do
    uploader = CarrierWave::Uploader::Base.new
    @storage = Whitehall::AssetManagerAndQuarantinedFileStorage.new(uploader)
    @file = CarrierWave::SanitizedFile.new(Tempfile.new('asset'))

    @asset_manager_storage = stub('asset-manager-storage')
    Whitehall::AssetManagerStorage.stubs(:new).returns(@asset_manager_storage)
    @quarantined_file_storage = stub('quarantined-file-storage')
    Whitehall::QuarantinedFileStorage.stubs(:new).returns(@quarantined_file_storage)

    Whitehall.stubs(:use_asset_manager).returns(true)
  end

  test 'stores the file using the asset manager storage engine' do
    @asset_manager_storage.expects(:store!).with(@file)
    @quarantined_file_storage.stubs(:store!)

    @storage.store!(@file)
  end

  test 'does not store the file using the asset manager storage engine when feature flag is off' do
    Whitehall.stubs(:use_asset_manager).returns(false)

    @asset_manager_storage.expects(:store!).never
    @quarantined_file_storage.stubs(:store!)

    @storage.store!(@file)
  end

  test 'stores the file using the quarantined file storage engine' do
    @asset_manager_storage.stubs(:store!)
    @quarantined_file_storage.expects(:store!).with(@file)

    @storage.store!(@file)
  end

  test 'returns the value returned from the quarantined file store' do
    @asset_manager_storage.stubs(:store!)
    @quarantined_file_storage.stubs(:store!).with(@file).returns('stored-file')

    assert_equal 'stored-file', @storage.store!(@file)
  end

  test 'retrieves the file from the quarantined file store' do
    @asset_manager_storage.stubs(:store!)
    @quarantined_file_storage.stubs(:retrieve!).with('identifier').returns('retrieved-file')

    assert_equal 'retrieved-file', @storage.retrieve!('identifier')
  end
end
