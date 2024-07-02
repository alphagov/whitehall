require "test_helper"

class ContentObjectStore::SchemaTest < ActiveSupport::TestCase
  test "it generates a human-readable name" do
    schema = ContentObjectStore::Schema.new("content_block_email_address")

    assert_equal schema.name, "Email address"
  end

  test "it generates a parameterized name for use in URLs" do
    schema = ContentObjectStore::Schema.new("content_block_email_address")

    assert_equal schema.parameter, "email-address"
  end
end
