require "test_helper"

class ContentBlockManager::ContentBlock::Schema::EmbeddedSchemaTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:body) do
    {
      "type" => "object",
      "patternProperties" => {
        "*" => {
          "type" => "object",
          "properties" => properties,
        },
      },
    }
  end
  let(:properties) do
    {
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

  describe "#group" do
    describe "when a group is given in config" do
      it "returns the subschemas default name" do
        ContentBlockManager::ContentBlock::Schema::EmbeddedSchema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  "bar" => {
                    "group" => "a_group",
                  },
                },
              },
            },
          })

        assert_equal "a_group", schema.group
      end
    end

    describe "when a group is not given in config" do
      it "returns nil" do
        assert_equal nil, schema.group
      end
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

  describe "#group_order" do
    describe "when set in the config" do
      before do
        ContentBlockManager::ContentBlock::Schema::EmbeddedSchema
          .stubs(:schema_settings)
          .returns({
            "schemas" => {
              parent_schema_id => {
                "subschemas" => {
                  schema_id => {
                    "group_order" => "12",
                  },
                },
              },
            },
          })
      end

      it "returns the group order as an integer" do
        assert_equal schema.group_order, 12
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

      it "returns infinity to put the item at the end of the group" do
        assert_equal schema.group_order, Float::INFINITY
      end
    end
  end

  describe "#permitted_params" do
    it "returns permitted params" do
      assert_equal schema.permitted_params, %w[title amount description frequency]
    end

    describe "when some fields have nested fields" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "foo" => {
            "type" => "object",
            "properties" => {
              "my_string" => {},
            },
          },
          "bar" => {
            "type" => "string",
          },
        }
      end

      it "returns permitted params" do
        assert_equal schema.permitted_params, ["title", { "foo" => %w[my_string] }, "bar"]
      end
    end

    describe "when some fields have an array type" do
      let(:properties) do
        {
          "title" => {
            "type" => "string",
          },
          "foo" => {
            "type" => "array",
            "items" => {
              "type" => "string",
            },
          },
          "bar" => {
            "type" => "array",
            "items" => {
              "type" => "object",
              "properties" => {
                "my_string" => {},
              },
            },
          },
        }
      end

      it "returns permitted params" do
        assert_equal schema.permitted_params, ["title", { "foo" => [] }, { "bar" => %w[my_string] }]
      end
    end
  end
end
