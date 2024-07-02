require "test_helper"

class ContentObjectStore::SchemaTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:body) { { "properties" => { "foo" => {}, "bar" => {} } } }
  let(:schema) { ContentObjectStore::ContentBlockSchema.new("content_block_email_address", body) }

  test "it generates a human-readable name" do
    assert_equal schema.name, "Email address"
  end

  test "it generates a parameterized name for use in URLs" do
    assert_equal schema.parameter, "email-address"
  end

  test "it returns all fields" do
    assert_equal schema.fields, %w[foo bar]
  end
end
