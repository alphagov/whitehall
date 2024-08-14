require "test_helper"

class ContentObjectStore::ContentBlockEdition::New::ErrorSummaryComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:component) do
    ContentObjectStore::ContentBlockEdition::New::ErrorSummaryComponent.new(error_message:)
  end

  describe "when a message is present" do
    let(:error_message) { "Error message" }

    it "renders an error summary" do
      render_inline(component)

      assert_selector ".govuk-error-summary"
      assert_selector ".gem-c-error-summary__list-item", text: error_message
    end
  end

  describe "when a message is not present" do
    let(:error_message) { nil }

    it "does not render a summary" do
      render_inline(component)

      assert_no_selector ".govuk-error-summary"
    end
  end
end
