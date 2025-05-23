require "test_helper"

class ShowMethodsTestClass
  class << self
    def helper_method(method)
      @helper_methods ||= []
      @helper_methods << method
    end
  end

  include Workflow::ShowMethods

  attr_reader :current_step, :previous_step

  def initialize(current_step:, previous_step:, content_block_edition:)
    @current_step = current_step
    @previous_step = previous_step
    @content_block_edition = content_block_edition
  end

  # This allows us to access the URL helpers in the same way as if this
  # were a controller
  def content_block_manager
    ContentBlockManager::Engine.routes.url_helpers
  end
end

class Workflow::ShowMethodsTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL
  include Rails.application.routes.url_helpers

  describe "#back_path" do
    let(:content_block_edition) { build_stubbed(:content_block_edition) }

    it "returns the name of the previous step" do
      expected_step_name = "something"

      current_step = mock("Workflow::Step")
      previous_step = mock("Workflow::Step", name: expected_step_name)

      test_class = ShowMethodsTestClass.new(current_step:, previous_step:, content_block_edition:)

      assert_equal test_class.back_path, content_block_manager.content_block_manager_content_block_workflow_path(
        content_block_edition,
        step: expected_step_name,
      )
    end
  end
end
