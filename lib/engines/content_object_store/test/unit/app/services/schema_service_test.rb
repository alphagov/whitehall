require "test_helper"

class ContentObjectStore::SchemaServiceTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "schema_for_block_type" do
    test "it returns the schema when the block_type is valid" do
      block_type = "email_address"
      response = {
        "definitions" => {
          "details" => {
            "type" => "object",
            "required" => %w[email_address],
            "additionalProperties" => false,
            "properties" => {
              "email_address" => {
                "type" => "string",
                "format" => "email",
              },
            },
          },
        },
      }
      Services.publishing_api.expects(:get_schema)
              .with("content_block_#{block_type}")
              .at_least_once.returns(response)

      schema = ContentObjectStore::SchemaService.schema_for_block_type(block_type)

      assert_equal schema, response["definitions"]["details"]
    end

    test "it throws an error when the block type is not valid" do
      block_type = "something_else"
      Services.publishing_api.expects(:get_schema)
              .with("content_block_#{block_type}")
              .at_least_once.raises(GdsApi::HTTPNotFound)

      assert_raises ArgumentError, "Invalid block_type: #{block_type}" do
        ContentObjectStore::SchemaService.schema_for_block_type(block_type)
      end
    end

    test "it throws a useful error when there is no details object present" do
      block_type = "email_address"
      Services.publishing_api.expects(:get_schema)
              .with("content_block_#{block_type}")
              .at_least_once.returns({})
      assert_raises ArgumentError, "Cannot find schema for #{block_type}" do
        ContentObjectStore::SchemaService.schema_for_block_type(block_type)
      end
    end
  end

  describe "valid schemas" do
    let(:response) do
      {
        "something" => {},
        "something_else" => {},
        "content_block_foo" => {},
        "content_block_bar" => {},
      }
    end

    before(:all) do
      Services.publishing_api.expects(:get_schemas)
              .once.returns(response)
    end

    it "returns a list of schemas with the content block prefix" do
      schemas = ContentObjectStore::SchemaService.valid_schemas
      assert_equal schemas.map(&:id), %w[content_block_foo content_block_bar]
    end

    it "memoizes the result" do
      # Mocha won't let us assert how many times something was called, so
      # given that we only expect Publishing API to be called once, let's
      # call our service method twice and assert that no errors were raised
      assert_nothing_raised do
        2.times { ContentObjectStore::SchemaService.valid_schemas }
      end
    end
  end
end
