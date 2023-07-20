require "test_helper"

class WhitehallUploaderTest < ActiveSupport::TestCase
  test "indicates that assets are not protected" do
    assert_not WhitehallUploader.new.assets_protected?
  end
end
