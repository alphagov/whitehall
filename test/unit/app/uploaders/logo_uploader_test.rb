require "test_helper"

class LogoUploaderTest < ActiveSupport::TestCase
  test "uses the default storage engine" do
    assert_equal Storage::DefaultStorage, LogoUploader.storage
  end
end
