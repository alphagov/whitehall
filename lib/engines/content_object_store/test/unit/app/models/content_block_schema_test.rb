require "test_helper"

class ContentObjectStore::SchemaTest < ActiveSupport::TestCase
  test "it generates a human-readable name" do
    schema = ContentObjectStore::Schema.new("content_block_email_address")

    assert_equal schema.name, "Email address"
  end
end
