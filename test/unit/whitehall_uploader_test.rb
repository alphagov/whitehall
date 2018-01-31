require 'test_helper'

class WhitehallUploaderTest < ActiveSupport::TestCase
  test 'indicates that assets are not protected' do
    refute WhitehallUploader.new.assets_protected?
  end
end
