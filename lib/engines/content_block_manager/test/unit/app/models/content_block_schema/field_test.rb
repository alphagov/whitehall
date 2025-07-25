require "test_helper"

class ContentBlockManager::ContentBlock::Schema::FieldTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:schema) { build(:content_block_schema) }
  let(:field) { ContentBlockManager::ContentBlock::Schema::Field.new("something", schema) }

  let(:config) { {} }
  let(:body) { {} }

  before do
    schema.stubs(:config).returns(config)
    schema.stubs(:body).returns(body)
  end

  it "returns the name when cast as a string" do
    assert_equal "something", field.to_s
  end

  describe "#component_name" do
    describe "when there is no custom component set" do
      describe "when the field is a string" do
        let(:body) do
          { "properties" => { "something" => { "type" => "string" } } }
        end

        it "returns string" do
          assert_equal "string", field.component_name
        end
      end

      describe "when the field has enum values" do
        let(:body) do
          { "properties" => { "something" => { "type" => "string", "enum" => %w[foo bar] } } }
        end

        it "returns enum" do
          assert_equal "enum", field.component_name
        end
      end
    end

    describe "when there is a custom component set" do
      let(:config) do
        { "fields" => { "something" => { "component" => "custom" } } }
      end

      it "returns the custom component name" do
        assert_equal "custom", field.component_name
      end
    end

    describe "when the field is an object" do
      let(:body) do
        { "properties" => { "something" => { "type" => "object" } } }
      end

      it "returns object" do
        assert_equal "object", field.component_name
      end
    end
  end

  describe "#enum_values" do
    describe "when the field has enum values" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "enum" => %w[foo bar] } } }
      end

      it "returns enum" do
        assert_equal %w[foo bar], field.enum_values
      end
    end

    describe "when the field has no enum values" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string" } } }
      end

      it "returns enum" do
        assert_nil field.enum_values
      end
    end
  end

  describe "#default_value" do
    describe "when the field has a default value" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string", "default" => "bar" } } }
      end

      it "returns enum" do
        assert_equal "bar", field.default_value
      end
    end

    describe "when the field has no defaut value" do
      let(:body) do
        { "properties" => { "something" => { "type" => "string" } } }
      end

      it "returns enum" do
        assert_nil field.default_value
      end
    end
  end

  describe "#nested fields" do
    describe "when there are no nested fields present" do
      it "returns nil" do
        assert_equal nil, field.nested_fields
      end
    end

    describe "when there are nested fields present" do
      let(:body) do
        {
          "properties" => {
            "something" => {
              "type" => "object",
              "properties" => {
                "foo" => { "type" => "string" },
                "bar" => { "type" => "string", "enum" => %w[foo bar] },
              },
            },
          },
        }
      end

      it "returns nested fields" do
        nested_fields = field.nested_fields

        assert_equal nested_fields.count, 2

        assert_equal nested_fields[0].name, "foo"
        assert_equal nested_fields[1].name, "bar"

        assert_equal nested_fields[0].format, "string"
        assert_equal nested_fields[1].format, "string"

        assert_equal nested_fields[0].enum_values, nil
        assert_equal nested_fields[1].enum_values, %w[foo bar]
      end
    end
  end

  describe "nested_field(name)" do
    let(:body) do
      {
        "properties" => {
          "something" => {
            "type" => "object",
            "properties" => {
              "foo" => { "type" => "string" },
              "bar" => { "type" => "string", "enum" => %w[bat cat], "default" => "cat" },
            },
          },
        },
      }
    end

    context "when no name is given" do
      it "raises an error" do
        error = assert_raises(ArgumentError) do
          field.nested_field(nil)
        end
        assert_equal("Provide the name of a nested field", error.message)
      end
    end

    context "when a valid name is given" do
      let(:expected_match) do
        ContentBlockManager::ContentBlock::Schema::Field::NestedField.new(
          name: "bar",
          format: "string",
          enum_values: %w[bat cat],
          default_value: "cat",
        )
      end

      it "returns the nested field with the matching name" do
        assert_equal(
          expected_match,
          field.nested_field("bar"),
        )
      end
    end

    context "when an unknown name is given" do
      it "returns nil" do
        assert_nil(field.nested_field("unknown_name"))
      end
    end
  end

  describe "#array_items" do
    describe "when there are no properties present" do
      it "returns nil" do
        assert_nil field.array_items
      end
    end

    describe "when there are properties present" do
      let(:body) do
        {
          "properties" => {
            "something" => {
              "type" => "array",
              "items" => {
                "properties" => {
                  "foo" => { "type" => "string" },
                  "bar" => { "type" => "string", "enum" => %w[foo bar] },
                },
              },
            },
          },
        }
      end

      it "returns the array items" do
        assert_equal field.array_items, {
          "properties" => {
            "foo" => { "type" => "string" },
            "bar" => { "type" => "string", "enum" => %w[foo bar] },
          },
        }
      end

      describe "when an order is specified" do
        let(:config) do
          {
            "field_order" => %w[bar foo],
          }
        end

        it "returns the array items with the specified order" do
          assert_equal field.array_items, {
            "properties" => {
              "bar" => { "type" => "string", "enum" => %w[foo bar] },
              "foo" => { "type" => "string" },
            },
          }
        end
      end

      describe "when the array type is a string" do
        let(:body) do
          {
            "properties" => {
              "something" => {
                "type" => "array",
                "items" => {
                  "type" => "string",
                },
              },
            },
          }
        end

        it "returns successfully" do
          assert_equal field.array_items, { "type" => "string" }
        end
      end
    end
  end

  describe "#is_required?" do
    it "returns true when in the schema's required fields" do
      schema.stubs(:required_fields).returns(%w[something])

      assert_equal true, field.is_required?
    end

    it "returns false when note in the schema's required fields" do
      schema.stubs(:required_fields).returns(%w[else])

      assert_equal false, field.is_required?
    end
  end

  describe "#data_attributes" do
    describe "when a `data_attributes` config var is set" do
      let(:config) do
        { "fields" => { "something" => { "data_attributes" => { "foo" => "bar" } } } }
      end

      it "returns the data attributes" do
        assert_equal field.data_attributes, { "foo" => "bar" }
      end
    end

    describe "when a `data_attributes` config var is not set" do
      it "returns an empty hash" do
        assert_equal field.data_attributes, {}
      end
    end
  end
end
