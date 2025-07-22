require "test_helper"

class ContentBlockManager::ContentBlock::SchemaHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

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

  describe "#redirect_url_for_subschema" do
    let(:content_block_edition) { build_stubbed(:content_block_edition, :contact) }
    let(:subschema) { stub(:subschema, group:, id: "my_subschema") }

    context "when the subschema has a group" do
      let(:group) { nil }

      it "should generate a url with the subschema's step" do
        assert_equal redirect_url_for_subschema(subschema, content_block_edition), content_block_manager.content_block_manager_content_block_workflow_path(content_block_edition, step: "#{Workflow::Step::SUBSCHEMA_PREFIX}#{subschema.id}")
      end
    end

    context "when the subschema has no group" do
      let(:group) { "some_group" }

      it "should generate a url with the subschema's group" do
        assert_equal redirect_url_for_subschema(subschema, content_block_edition), content_block_manager.content_block_manager_content_block_workflow_path(content_block_edition, step: "#{Workflow::Step::GROUP_PREFIX}#{subschema.group}")
      end
    end
  end
end
