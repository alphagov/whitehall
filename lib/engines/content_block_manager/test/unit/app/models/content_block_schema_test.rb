require "test_helper"

class ContentBlockManager::SchemaTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:body) { { "properties" => { "foo" => {}, "bar" => {} } } }
  let(:schema) { build(:content_block_schema, :email_address, body:) }

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

  describe ".valid_schemas" do
    test "it returns the contents of the VALID_SCHEMA constant" do
      assert_equal ContentBlockManager::ContentBlock::Schema.valid_schemas, %w[
        email_address
        postal_address
      ]
    end
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
      Services.publishing_api.expects(:get_schemas).once.returns(response)
      ContentBlockManager::ContentBlock::Schema.stubs(:is_valid_schema?).with(anything).returns(false)
      ContentBlockManager::ContentBlock::Schema.stubs(:is_valid_schema?).with(any_of("content_block_foo", "content_block_bar")).returns(true)
    end

    it "returns a list of schemas with the content block prefix" do
      schemas = ContentBlockManager::ContentBlock::Schema.all
      assert_equal schemas.map(&:id), %w[content_block_foo content_block_bar]
      assert_equal schemas.map(&:fields), [%w[foo_field], %w[bar_field bar_field2]]
    end

    it "memoizes the result" do
      # Mocha won't let us assert how many times something was called, so
      # given that we only expect Publishing API to be called once, let's
      # call our service method twice and assert that no errors were raised
      assert_nothing_raised do
        2.times { ContentBlockManager::ContentBlock::Schema.all }
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
      ContentBlockManager::ContentBlock::Schema.stubs(:all).returns([
        build(:content_block_schema, block_type:, body:),
        build(:content_block_schema, block_type: "something_else", body: {}),
      ])
    end

    test "it returns the schema when the block_type is valid" do
      schema = ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)

      assert_equal schema.id, "content_block_#{block_type}"
      assert_equal schema.block_type, block_type
      assert_equal schema.fields, %w[email_address]
    end

    test "it throws an error when the schema  cannot be found for the block type" do
      block_type = "other_thing"

      assert_raises ArgumentError, "Cannot find schema for #{block_type}" do
        ContentBlockManager::ContentBlock::Schema.find_by_block_type(block_type)
      end
    end
  end

  describe ".is_valid_schema?" do
    test "returns true when the schema has correct prefix/suffix" do
      ContentBlockManager::ContentBlock::Schema.valid_schemas.each do |schema|
        schema_name = "#{ContentBlockManager::ContentBlock::Schema::SCHEMA_PREFIX}_#{schema}"
        assert ContentBlockManager::ContentBlock::Schema.is_valid_schema?(schema_name)
      end
    end

    test "returns false when given an invalid schema" do
      schema_name = "something_else"
      assert_equal ContentBlockManager::ContentBlock::Schema.is_valid_schema?(schema_name), false
    end

    test "returns false when the schema has correct prefix but a suffix that is not valid" do
      schema_name = "#{ContentBlockManager::ContentBlock::Schema::SCHEMA_PREFIX}_something"
      assert_equal ContentBlockManager::ContentBlock::Schema.is_valid_schema?(schema_name), false
    end
  end
end
