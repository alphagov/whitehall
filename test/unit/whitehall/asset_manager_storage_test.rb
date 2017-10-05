require 'test_helper'
require 'whitehall/asset_manager_storage'

class Whitehall::AssetManagerStorageTest < ActiveSupport::TestCase
  class AssetManagerUploader < CarrierWave::Uploader::Base
    storage :asset_manager
  end

  setup do
    @file = Tempfile.new('asset')
    @uploader = AssetManagerUploader.new
    @worker = mock('asset-manager-worker')
    AssetManagerWorker.stubs(:new).returns(@worker)
    FileUtils.mkdir_p(Whitehall.asset_manager_tmp_dir)
  end

  teardown do
    FileUtils.remove_dir(Whitehall.asset_manager_tmp_dir, true)
  end

  test "creates a sidekiq job using the location of the file in the asset manager tmp directory" do
    @worker.expects(:perform).with do |actual_path, _|
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
    @worker.expects(:perform).with(anything, expected_path)

    @uploader.store!(@file)
  end

  test 'returns the sanitized file' do
    @worker.stubs(:perform)

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
end
