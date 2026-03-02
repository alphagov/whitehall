require "test_helper"

class ImageUsageTest < ActiveSupport::TestCase
  test "caption_enabled defaults to true" do
    usage = ImageUsage.new(key: "header", kinds: [], multiple: false)
    assert usage.caption_enabled?
  end

  test "caption_enabled can be set to false" do
    usage = ImageUsage.new(key: "header", kinds: [], multiple: false, caption_enabled: false)
    assert_not usage.caption_enabled?
  end

  test "caption_enabled can be set to true explicitly" do
    usage = ImageUsage.new(key: "header", kinds: [], multiple: false, caption_enabled: true)
    assert usage.caption_enabled?
  end
end
