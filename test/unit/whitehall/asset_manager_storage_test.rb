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
  end

  test 'creates a sidekiq job using the file passed to the uploader' do
    @worker.expects(:perform).with(&same_content_as(@file))

    @uploader.store!(@file)
  end

  test 'creates a sidekiq job using an instance of a file object' do
    @worker.expects(:perform).with do |file, _|
      file.is_a?(File)
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

private

  def same_content_as(expected_file)
    -> (actual_file, _) {
      actual_file.read == expected_file.read
    }
  end
end
