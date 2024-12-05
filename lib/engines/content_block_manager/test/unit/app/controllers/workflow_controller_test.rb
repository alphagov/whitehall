require "test_helper"

class ContentBlockManager::ContentBlock::WorkflowControllerTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "confirmation_copy" do
    it "returns copy when edition is scheduled" do
      expected_result = ContentBlockManager::ContentBlock::Editions::WorkflowController::CONFIRMATION_COPY.new()
      actual_result = ContentBlockManager::ContentBlock::Editions::WorkflowController.confirmation_copy

    end
  end
end