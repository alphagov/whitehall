require 'test_helper'

class CarrierWave::SanitizedFileTest < ActiveSupport::TestCase

  test '#url returns a clean path relative to /public when given a full path to a clean file' do
    full_path = File.join(Whitehall.clean_upload_path, 'path/to/file.jpg')
    assert_equal '/government/uploads/path/to/file.jpg', CarrierWave::SanitizedFile.new(full_path).url
  end

  test '#url returns a clean path relative to /public when given a full path to a quaranteened file' do
    full_path = File.join(CarrierWave::Uploader::Base.incoming_root, 'path/to/file.jpg')
    assert_equal '/government/uploads/path/to/file.jpg', CarrierWave::SanitizedFile.new(full_path).url
  end
end
