require "test_helper"

class ContentBlockManager::WorkflowHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  include WorkflowHelper

  let(:content_block_edition) { build_stubbed(:content_block_edition) }
  let(:stub_document) { stub(:document, is_new_block?: is_new_block) }

  before do
    content_block_edition.stubs(:document).returns(stub_document)
  end

  describe "#back_path" do
    describe "when editing an existing block" do
      let(:is_new_block) { false }

      it "returns the name of the next step" do
        current_step_name = "my_step"
        expected_step_name = "something"

        current_step = mock("Workflow::Step")
        previous_step = mock("Workflow::Step", name: expected_step_name)

        Workflow::Step.expects(:by_name).with(current_step_name).returns(current_step)
        current_step.expects(:previous_step).returns(previous_step)

        assert_equal back_path(content_block_edition, current_step_name), content_block_manager.content_block_manager_content_block_workflow_path(
          content_block_edition,
          step: expected_step_name,
        )
      end
    end
  end

  describe "when editing an existing block" do
    let(:is_new_block) { true }

    it "returns the homepage link for the review step" do
      assert_equal back_path(content_block_edition, "review"), content_block_manager.content_block_manager_content_block_documents_path
    end
  end
end
