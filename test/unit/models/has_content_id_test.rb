require 'test_helper'

class HasContentIdTest < ActiveSupport::TestCase
  class TestObject
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks
    include HasContentId

    attr_accessor :content_id
  end

  test "it generates a uuid content id" do
    expected_content_id = SecureRandom.uuid
    SecureRandom.stubs(uuid: expected_content_id)
    object = TestObject.new

    object.validate

    assert_equal object.content_id, expected_content_id
  end
end
