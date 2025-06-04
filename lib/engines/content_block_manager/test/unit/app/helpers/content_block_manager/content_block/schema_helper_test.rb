require "test_helper"

class ContentBlockManager::ContentBlock::SchemaHelperTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  include ContentBlockManager::ContentBlock::SchemaHelper

  let(:schema) { stub(:schema) }

  let(:group_1_subschemas) do
    [
      stub(:subschema, group: "group_1"),
      stub(:subschema, group: "group_1"),
    ]
  end

  let(:group_2_subschemas) do
    [
      stub(:subschema, group: "group_2"),
      stub(:subschema, group: "group_2"),
      stub(:subschema, group: "group_2"),
    ]
  end

  let(:subschemas_without_groups) do
    [
      stub(:subschema, group: nil),
      stub(:subschema, group: nil),
      stub(:subschema, group: nil),
      stub(:subschema, group: nil),
      stub(:subschema, group: nil),
    ]
  end

  before do
    schema.stubs(:subschemas).returns([*group_1_subschemas, *group_2_subschemas, *subschemas_without_groups])
  end

  describe "#grouped_subschemas" do
    it "returns all grouped subschemas" do
      assert_equal grouped_subschemas(schema), { "group_1" => group_1_subschemas, "group_2" => group_2_subschemas }
    end
  end

  describe "#ungrouped_subschemas" do
    it "returns all ungrouped subschemas" do
      assert_equal ungrouped_subschemas(schema), subschemas_without_groups
    end
  end
end
