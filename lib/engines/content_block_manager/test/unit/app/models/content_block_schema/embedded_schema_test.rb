require "test_helper"

class ContentBlockManager::ContentBlock::Schema::EmbeddedSchemaTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:body) do
    {
      "type" => "object",
      "patternProperties" => {
        "*" => {
          "type" => "object",
          "properties" => {
            "name" => {
              "type" => "string",
            },
            "amount" => {
              "type" => "string",
            },
            "description" => {
              "type" => "string",
            },
            "frequency" => {
              "type" => "string",
            },
          },
        },
      },
    }
  end
  let(:schema_id) { "bar" }
  let(:parent_schema_id) { "parent_schema_id" }
  let(:schema) { ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new(schema_id, body, parent_schema_id) }

  it "returns the subschema id" do
    assert_equal schema.id, schema_id
  end

  it "returns the fields" do
    assert_equal schema.fields.map(&:name), %w[name amount description frequency]
  end

  describe "when an order is given in the subschema" do
    let(:body_with_order) do
      body["patternProperties"]["*"] = body["patternProperties"]["*"].merge("order" => %w[amount frequency name description])
      body
    end

    let(:schema) { ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new("bar", body_with_order, parent_schema_id) }

    it "orders fields" do
      assert_equal schema.fields.map(&:name), %w[amount frequency name description]
    end
  end

  describe "when an order is given in the config" do
    before do
      ContentBlockManager::ContentBlock::Schema::EmbeddedSchema
        .stubs(:schema_settings)
        .returns({
          "schemas" => {
            parent_schema_id => {
              "subschemas" => {
                schema_id => {
                  "field_order" => %w[name frequency amount description],
                },
              },
            },
          },
        })
    end

    it "orders fields" do
      assert_equal schema.fields.map(&:name), %w[name frequency amount description]
    end
  end

  describe "when an order is given in the config and the schema" do
    let(:body_with_order) do
      body["patternProperties"]["*"] = body["patternProperties"]["*"].merge("order" => %w[amount frequency name description])
      body
    end

    let(:schema) { ContentBlockManager::ContentBlock::Schema::EmbeddedSchema.new("bar", body_with_order, parent_schema_id) }

    before do
      ContentBlockManager::ContentBlock::Schema::EmbeddedSchema
        .stubs(:schema_settings)
        .returns({
          "schemas" => {
            parent_schema_id => {
              "subschemas" => {
                schema_id => {
                  "field_order" => %w[name frequency amount description],
                },
              },
            },
          },
        })
    end

    it "prioritises the config order" do
      assert_equal schema.fields.map(&:name), %w[name frequency amount description]
    end
  end

  describe "when no order is given" do
    before do
      ContentBlockManager::ContentBlock::Schema
        .stubs(:schema_settings)
        .returns({})
    end

    it "maintains the default order" do
      assert_equal schema.fields.map(&:name), %w[name amount description frequency]
    end
  end

  describe "when an invalid subschema is given" do
    let(:body) do
      {
        "properties" => {
          "foo" => {
            "type" => "string",
          },
          "bar" => {
            "type" => "object",
            "properties" => {
              "my_string" => {
                "type" => "string",
              },
              "something_else" => {
                "type" => "string",
              },
            },
          },
        },
      }
    end

    it "raises an error" do
      assert_raises ArgumentError, "Subschema `bar` is invalid" do
        schema
      end
    end
  end
end
