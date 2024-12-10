require "test_helper"

class ContentBlockManager::ContentBlock::Document::Index::DateFilterComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  it "renders from and to dates" do
    render_inline(ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent.new)
    assert_selector "input[name='last_updated_from[1i]']"
    assert_selector "input[name='last_updated_from[2i]']"
    assert_selector "input[name='last_updated_from[3i]']"

    assert_selector "input[name='last_updated_to[1i]']"
    assert_selector "input[name='last_updated_to[2i]']"
    assert_selector "input[name='last_updated_to[3i]']"
  end

  it "keeps the values from the filter params" do
    filters = {
      last_updated_from: {
        "3i" => "1",
        "2i" => "2",
        "1i" => "2025",
      },
      last_updated_to: {
        "3i" => "3",
        "2i" => "4",
        "1i" => "2026",
      },
    }
    render_inline(ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent.new(filters:))

    assert_selector "input[name='last_updated_from[3i]'][value=1]"
    assert_selector "input[name='last_updated_from[2i]'][value='2']"
    assert_selector "input[name='last_updated_from[1i]'][value='2025']"

    assert_selector "input[name='last_updated_to[3i]'][value='3']"
    assert_selector "input[name='last_updated_to[2i]'][value='4']"
    assert_selector "input[name='last_updated_to[1i]'][value='2026']"
  end

  it "renders errors if there are errors on the date filter" do
    errors = [
      ContentBlockManager::ContentBlock::Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_from", full_message: "From date is not in the correct format",
      ),
      ContentBlockManager::ContentBlock::Document::DocumentFilter::FILTER_ERROR.new(
        attribute: "last_updated_to", full_message: "To date is not in the correct format",
      ),
    ]
    render_inline(ContentBlockManager::ContentBlock::Document::Index::DateFilterComponent.new(errors:))

    assert_selector ".govuk-error-message", text: "From date is not in the correct format"
    assert_selector ".govuk-error-message", text: "To date is not in the correct format"
  end
end
