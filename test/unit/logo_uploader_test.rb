require 'test_helper'

class LogoUploaderTest < ActiveSupport::TestCase
  test 'uses the asset manager storage engine' do
    assert_equal Whitehall::AssetManagerStorage, LogoUploader.storage
  end
end
