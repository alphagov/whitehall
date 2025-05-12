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
end
