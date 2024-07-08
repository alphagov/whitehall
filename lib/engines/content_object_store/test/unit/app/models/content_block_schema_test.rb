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
end
