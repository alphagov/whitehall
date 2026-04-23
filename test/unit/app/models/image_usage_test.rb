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

  test "default title is \"`key` image\"" do
    usage = ImageUsage.new(key: "header", kinds: [], multiple: false, caption_enabled: true)
    assert_equal "header image", usage.title
  end

  test "title uses label as override if provided" do
    usage = ImageUsage.new(key: "logo", label: "header logo", kinds: [], multiple: false, caption_enabled: true)
    assert_equal "header logo", usage.title
  end

  test "title is `image` if embeddable (default) image usage" do
    usage = ImageUsage.new(key: "govspeak_embed", kinds: [], multiple: false, caption_enabled: true)
    assert_equal "image", usage.title
  end
end
