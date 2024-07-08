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

  test "it returns a block type" do
    assert_equal schema.block_type, "email_address"
  end

  describe ".all" do
    let(:response) do
      {
        "something" => {},
        "something_else" => {},
        "content_block_foo" => {
          "definitions" => {
            "details" => {
              "properties" => {
                "foo_field" => {
                  "type" => "string",
                },
              },
            },
          },
        },
        "content_block_bar" => {
          "definitions" => {
            "details" => {
              "properties" => {
                "bar_field" => {
                  "type" => "string",
                },
                "bar_field2" => {
                  "type" => "string",
                },
              },
            },
          },
        },
        "content_block_invalid" => {},
      }
    end

    before(:all) do
      Services.publishing_api.expects(:get_schemas)
              .once.returns(response)
    end

    it "returns a list of schemas with the content block prefix" do
      schemas = ContentObjectStore::ContentBlockSchema.all
      assert_equal schemas.map(&:id), %w[content_block_foo content_block_bar]
      assert_equal schemas.map(&:fields), [%w[foo_field], %w[bar_field bar_field2]]
    end

    it "memoizes the result" do
      # Mocha won't let us assert how many times something was called, so
      # given that we only expect Publishing API to be called once, let's
      # call our service method twice and assert that no errors were raised
      assert_nothing_raised do
        2.times { ContentObjectStore::ContentBlockSchema.all }
      end
    end
  end

  describe ".find_by_block_type" do
    let(:block_type) { "email_address" }
    let(:body) do
      {
        "properties" => {
          "email_address" => {
            "type" => "string",
            "format" => "email",
          },
        },
      }
    end

    setup do
      ContentObjectStore::ContentBlockSchema.stubs(:all).returns([
        ContentObjectStore::ContentBlockSchema.new("content_block_#{block_type}", body),
        ContentObjectStore::ContentBlockSchema.new("content_block_something_else", {}),
      ])
    end

    test "it returns the schema when the block_type is valid" do
      schema = ContentObjectStore::ContentBlockSchema.find_by_block_type(block_type)

      assert_equal schema.id, "content_block_#{block_type}"
      assert_equal schema.block_type, block_type
      assert_equal schema.fields, %w[email_address]
    end

    test "it throws an error when the schema  cannot be found for the block type" do
      block_type = "other_thing"

      assert_raises ArgumentError, "Cannot find schema for #{block_type}" do
        ContentObjectStore::ContentBlockSchema.find_by_block_type(block_type)
      end
    end
  end
end
