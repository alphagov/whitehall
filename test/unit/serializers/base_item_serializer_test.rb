require "test_helper"
require 'active_model_serializers'

class BaseItemSerializerTest < ActiveSupport::TestCase
  def stubbed_item
    stub(title: 'A title', need_ids: [1, 2])
  end

  def serializer
    BaseItemSerializer.new(stubbed_item)
  end

  test "it has a title" do
    assert_equal serializer.title, stubbed_item.title
  end

  test "it has need ids" do
    assert_equal serializer.need_ids, stubbed_item.need_ids
  end

  test "it has a publishing app" do
    assert_equal serializer.publishing_app, "whitehall"
  end

  test "it includes redirects" do
    assert_equal serializer.redirects, []
  end

  test "it includes a locale" do
    assert_equal serializer.locale, "en"
  end
end
