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
            "amount" => {
              "type" => "string",
            },
            "description" => {
              "type" => "string",
            },
            "frequency" => {
              "type" => "string",
            },
            "title" => {
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
    assert_equal schema.fields.map(&:name), %w[title amount description frequency]
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
                  "field_order" => %w[frequency amount description title],
                },
              },
            },
          },
        })
    end

    it "orders fields" do
      assert_equal schema.fields.map(&:name), %w[frequency amount description title]
    end
  end

  describe "when no order is given" do
    before do
      ContentBlockManager::ContentBlock::Schema
        .stubs(:schema_settings)
        .returns({})
    end

    it "prioritises the title" do
      assert_equal schema.fields.map(&:name), %w[title amount description frequency]
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

  describe "#embeddable_as_block?" do
    describe "when set in the config" do
      before do
        ContentBlockManager::ContentBlock::Schema::EmbeddedSchema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {
                    "embeddable_as_block" => true,
                  },
                },
              },
            },
          })
      end

      it "returns true" do
        assert schema.embeddable_as_block?
      end
    end

    describe "when not set in the config" do
      before do
        ContentBlockManager::ContentBlock::Schema::EmbeddedSchema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {},
                },
              },
            },
          })
      end

      it "returns false" do
        assert_not schema.embeddable_as_block?
      end
    end
  end
end
