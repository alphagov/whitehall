require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::DateFilterComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  it "renders from and to dates" do
    render_inline(ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent.new)
    assert_selector "input[name='last_updated[from(1i)]']"
    assert_selector "input[name='last_updated[from(2i)]']"
    assert_selector "input[name='last_updated[from(3i)]']"

    assert_selector "input[name='last_updated[to(1i)]']"
    assert_selector "input[name='last_updated[to(2i)]']"
    assert_selector "input[name='last_updated[to(3i)]']"
  end
end
