require "test_helper"

class ContentBlockManager::ContentBlock::WorkflowTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  describe "Step" do
    describe ".by_name" do
      it "returns a step by its name" do
        step = Workflow::Step.by_name("review_links")

        assert_equal step&.name, :review_links
      end
    end

    describe "#next_step" do
      [
        %i[edit_draft review_links],
        %i[review_links schedule_publishing],
        %i[schedule_publishing internal_note],
        %i[internal_note change_note],
        %i[change_note review],
        %i[review confirmation],
      ].each do |current_step, expected_step|
        it "returns #{expected_step} step when the current step is #{current_step}" do
          step = Workflow::Step.by_name(current_step)
          assert_equal step&.next_step&.name, expected_step
        end
      end
    end

    describe "#previous_step" do
      [
        %i[review_links edit_draft],
        %i[schedule_publishing review_links],
        %i[internal_note schedule_publishing],
        %i[change_note internal_note],
        %i[review change_note],
      ].each do |current_step, expected_step|
        it "returns #{expected_step} step when the current step is #{current_step}" do
          step = Workflow::Step.by_name(current_step)
          assert_equal step&.previous_step&.name, expected_step
        end
      end
    end
  end
end
