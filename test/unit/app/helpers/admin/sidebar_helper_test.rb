require "test_helper"

class Admin::SidebarHelperTest < ActionView::TestCase
  extend Minitest::Spec::DSL

  before do
    test_strategy = Flipflop::FeatureSet.current.test!
    test_strategy.switch!(:show_link_to_content_block_manager, content_block_enabled)
  end

  context "when #show_link_to_content_block_manager? is false" do
    let(:content_block_enabled) { false }

    it "does not include content block guidance" do
      result = simple_formatting_sidebar
      assert_includes result, "Formatting"
      assert_includes result, "Use plain English"
      assert_not_includes result, "Content block"
    end
  end

  context "when #show_link_to_content_block_manager? is true" do
    let(:content_block_enabled) { true }

    it "includes content block guidance" do
      result = simple_formatting_sidebar
      assert_includes result, "Formatting"
      assert_includes result, "Use plain English"
      assert_includes result, "Content block"
    end
  end
end
