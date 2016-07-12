require "test_helper"
require 'active_model_serializers'

class PublicDocumentPathSerializerTest < ActiveSupport::TestCase
  def serializer
    PublicDocumentPathSerializer.new(stub)
  end

  test "it has a base_path" do
    Whitehall.url_maker.stub(:public_document_path, 'a/path', locale: 'en') do
      assert_equal serializer.base_path, 'a/path'
    end
  end

  test "it has routes" do
    Whitehall.url_maker.stub(:public_document_path, 'a/path', locale: 'en') do
      assert_equal serializer.routes, [{path: 'a/path', type: 'exact'}]
    end
  end
end
