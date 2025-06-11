require "test_helper"

class ContentBlockManager::ContentBlock::Schema::Field::NestedFieldTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  extend Minitest::Spec::DSL

  let(:schema) { build(:content_block_schema) }
  let(:field) do
    ContentBlockManager::ContentBlock::Schema::Field::NestedField.new(
      name: "something",
      parent_name: "parent",
      schema:,
      properties: properties,
      config: config,
    )
  end

  let(:properties) { {} }
  let(:config) { {} }

  it "returns the name when cast as a string" do
    assert_equal "something", field.to_s
  end

  describe "#component_name" do
    describe "when there is no custom component set" do
      describe "when the field is a string" do
        let(:properties) do
          { "type" => "string" }
        end

        it "returns string" do
          assert_equal "string", field.component_name
        end
      end

      describe "when the field has enum values" do
        let(:properties) do
          { "type" => "string", "enum" => %w[foo bar] }
        end

        it "returns enum" do
          assert_equal "enum", field.component_name
        end
      end
    end

    describe "when there is a custom component set" do
      let(:config) do
         { "component" => "custom" }
      end

      it "returns the custom component name" do
        assert_equal "custom", field.component_name
      end
    end
  end

  describe "#enum_values" do
    describe "when the field has enum values" do
      let(:properties) do
        { "type" => "string", "enum" => %w[foo bar] }
      end

      it "returns enum" do
        assert_equal %w[foo bar], field.enum_values
      end
    end

    describe "when the field has no enum values" do
      let(:properties) do
        { "type" => "string" }
      end

      it "returns enum" do
        assert_nil field.enum_values
      end
    end
  end

  describe "#default_value" do
    describe "when the field has a default value" do
      let(:properties) do
        { "type" => "string", "default" => "bar" }
      end

      it "returns enum" do
        assert_equal "bar", field.default_value
      end
    end

    describe "when the field has no default value" do
      let(:properties) do
        { "type" => "string" }
      end

      it "returns enum" do
        assert_nil field.default_value
      end
    end
  end
end
