require "test_helper"

class WorkflowTestClass
  class << self
    def before_action(method)
      @before_actions ||= []
      @before_actions << method
    end
  end

  include Workflow::Steps

  attr_reader :params

  def initialize(params)
    @params = params
    self.class.instance_variable_get("@before_actions").each do |method|
      send(method)
    end
  end
end

class Workflow::StepsTest < ActionDispatch::IntegrationTest
  extend Minitest::Spec::DSL

  include ContentBlockManager::IntegrationTestHelpers

  let(:content_block_document) { build(:content_block_document, :email_address) }
  let(:content_block_edition) { build(:content_block_edition, :email_address, document: content_block_document) }

  let!(:schema) { stub_request_for_schema(content_block_document.block_type) }

  before do
    ContentBlockManager::ContentBlock::Edition.stubs(:find).with(content_block_edition.id).returns(content_block_edition)
  end

  let(:workflow) { WorkflowTestClass.new({ id: content_block_edition.id, step: }) }

  describe "#current_step" do
    Workflow::Step::ALL.each do |step|
      describe "when step name is #{step.name}" do
        let(:step) { step.name }

        it "returns the step" do
          assert_equal workflow.current_step, step
        end
      end
    end
  end

  describe "#next_step" do
    [
      %i[edit_draft review_links],
      %i[review_links internal_note],
      %i[internal_note change_note],
      %i[change_note schedule_publishing],
      %i[schedule_publishing review],
      %i[review confirmation],
    ].each do |current_step, expected_step|
      describe "when current_step is #{current_step}" do
        let(:step) { current_step }

        it "returns #{expected_step} step" do
          assert_equal workflow.next_step.name, expected_step
        end
      end
    end
  end

  describe "#previous_step" do
    [
      %i[review_links edit_draft],
      %i[internal_note review_links],
      %i[change_note internal_note],
      %i[schedule_publishing change_note],
      %i[review schedule_publishing],
    ].each do |current_step, expected_step|
      describe "when current_step is #{current_step}" do
        let(:step) { current_step }

        it "returns #{expected_step} step" do
          assert_equal workflow.previous_step.name, expected_step
        end
      end
    end
  end

  describe "when the content block is new" do
    let(:step) { "something" }

    before do
      content_block_document.expects(:is_new_block?).returns(true)
    end

    it "removes steps not included in the create journey" do
      assert_equal workflow.steps, [
        Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
        Workflow::Step.new(:review, :review, :validate_review_page, true),
        Workflow::Step.new(:confirmation, :confirmation, nil, true),
      ].flatten
    end

    describe "#next_step" do
      [
        %i[edit_draft review],
        %i[review confirmation],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            assert_equal workflow.next_step.name, expected_step
          end
        end
      end
    end

    describe "#previous_step" do
      [
        %i[review edit_draft],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            assert_equal workflow.previous_step.name, expected_step
          end
        end
      end
    end
  end

  describe "when a schema has subschemas" do
    let(:subschemas) do
      [
        stub("subschema", id: "something"),
        stub("subschema", id: "something_else"),
      ]
    end

    let!(:schema) { stub_request_for_schema(content_block_document.block_type, subschemas:) }

    let(:step) { "something" }

    describe "#steps" do
      it "inserts the subschemas into the flow" do
        assert_equal workflow.steps, [
          Workflow::Step::ALL[0],
          Workflow::Step.new(:embedded_something, :embedded_something, :redirect_to_next_step, true),
          Workflow::Step.new(:embedded_something_else, :embedded_something_else, :redirect_to_next_step, true),
          Workflow::Step::ALL[1..],
        ].flatten
      end
    end

    describe "#next_step" do
      [
        %i[edit_draft embedded_something],
        %i[embedded_something embedded_something_else],
        %i[embedded_something_else review_links],
        %i[review_links internal_note],
        %i[internal_note change_note],
        %i[change_note schedule_publishing],
        %i[schedule_publishing review],
        %i[review confirmation],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            assert_equal workflow.next_step.name, expected_step
          end
        end
      end
    end

    describe "#previous_step" do
      [
        %i[embedded_something edit_draft],
        %i[embedded_something_else embedded_something],
        %i[review_links embedded_something_else],
        %i[internal_note review_links],
        %i[change_note internal_note],
        %i[schedule_publishing change_note],
        %i[review schedule_publishing],
      ].each do |current_step, expected_step|
        describe "when current_step is #{current_step}" do
          let(:step) { current_step }

          it "returns #{expected_step} step" do
            assert_equal workflow.previous_step.name, expected_step
          end
        end
      end
    end

    describe "and the content block is new" do
      before do
        content_block_document.expects(:is_new_block?).returns(true)
      end

      it "removes steps not included in the create journey" do
        assert_equal workflow.steps, [
          Workflow::Step.new(:edit_draft, :edit_draft, :update_draft, true),
          Workflow::Step.new(:embedded_something, :embedded_something, :redirect_to_next_step, true),
          Workflow::Step.new(:embedded_something_else, :embedded_something_else, :redirect_to_next_step, true),
          Workflow::Step.new(:review, :review, :validate_review_page, true),
          Workflow::Step.new(:confirmation, :confirmation, nil, true),
        ].flatten
      end

      describe "#next_step" do
        [
          %i[edit_draft embedded_something],
          %i[embedded_something embedded_something_else],
          %i[embedded_something_else review],
          %i[review confirmation],
        ].each do |current_step, expected_step|
          describe "when current_step is #{current_step}" do
            let(:step) { current_step }

            it "returns #{expected_step} step" do
              assert_equal workflow.next_step.name, expected_step
            end
          end
        end
      end

      describe "#previous_step" do
        [
          %i[embedded_something edit_draft],
          %i[embedded_something_else embedded_something],
          %i[review embedded_something_else],
        ].each do |current_step, expected_step|
          describe "when current_step is #{current_step}" do
            let(:step) { current_step }

            it "returns #{expected_step} step" do
              assert_equal workflow.previous_step.name, expected_step
            end
          end
        end
      end
    end
  end
end
