require 'test_helper'

class QuarantinedFileStorageTest < ActiveSupport::TestCase
  test 'stores file by copying it to the incoming root directory' do
    uploader = stub('uploader', store_path: 'store-path', incoming_root: 'incoming-root', permissions: '600')
    storage = Whitehall::QuarantinedFileStorage.new(uploader)
    file = stub('file')
    File.stubs(:expand_path).with('store-path', 'incoming-root').returns('expanded-path')
    file.expects(:copy_to).with('expanded-path', '600')
    storage.store!(file)
  end

  test 'retrieves files from the clean directory' do
    uploader = stub('uploader', clean_root: 'clean-root')
    uploader.stubs(:store_path).with('file-identifier').returns('store-path')
    storage = Whitehall::QuarantinedFileStorage.new(uploader)
    File.stubs(:expand_path).with('store-path', 'clean-root').returns('expanded-path')
    retrieved_file = stub('retrieved-file')
    CarrierWave::SanitizedFile.stubs(:new).with('expanded-path').returns(retrieved_file)
    assert_equal retrieved_file, storage.retrieve!('file-identifier')
  end
end