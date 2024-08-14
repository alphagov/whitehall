require "test_helper"

class ContentObjectStore::ContentBlockEdition::New::SelectSchemaComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:heading) { "Some heading" }
  let(:heading_caption) { "Caption" }
  let(:error_message) { nil }
  let(:schemas) { build_list(:content_block_schema, 3) }

  let(:component) do
    ContentObjectStore::ContentBlockEdition::New::SelectSchemaComponent.new(
      heading:,
      heading_caption:,
      error_message:,
      schemas:,
    )
  end

  test "renders a select component with all the schemas" do
    render_inline(component)

    assert_selector ".govuk-fieldset__heading", text: heading
    assert_selector ".govuk-caption-xl", text: heading_caption
    assert_no_selector ".govuk-error-message"

    schemas.each do |s|
      assert_selector ".govuk-radios" do
        assert_selector "input[type='radio'][name='block_type'][value='#{s.parameter}']"
        assert_selector ".govuk-radios__label", text: s.name
      end
    end
  end

  describe "when an error message is present" do
    let(:error_message) { "Some error" }

    it "shows the error message" do
      render_inline(component)

      assert_selector ".govuk-error-message", text: error_message
    end
  end
end
