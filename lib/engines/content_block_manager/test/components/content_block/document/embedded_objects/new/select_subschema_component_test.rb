require "test_helper"

class ContentBlockManager::ContentBlock::Document::EmbeddedObjects::New::SelectSubschemaComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:heading) { "Some heading" }
  let(:heading_caption) { "Caption" }
  let(:error_message) { nil }
  let(:schemas) do
    [
      stub(:schema, id: "foo", name: "Foos"),
      stub(:schema, id: "bar", name: "Bars"),
      stub(:schema, id: "baz", name: "Bazzes"),
    ]
  end

  let(:component) do
    ContentBlockManager::ContentBlock::Document::EmbeddedObjects::New::SelectSubschemaComponent.new(
      heading:,
      heading_caption:,
      error_message:,
      schemas:,
    )
  end

  it "renders a select component with all the schemas" do
    render_inline(component)

    assert_selector ".govuk-fieldset__heading", text: heading
    assert_selector ".govuk-caption-xl", text: heading_caption
    assert_selector ".govuk-radios__item", count: 3

    assert_no_selector ".govuk-error-message"

    assert_selector ".govuk-radios" do |radios|
      radios.assert_selector ".govuk-radios__item", text: /Foo/ do |item|
        item.assert_selector "input[type='radio'][name='object_type'][value='foo']"
        item.assert_selector ".govuk-radios__label", text: "Foo"
      end

      radios.assert_selector ".govuk-radios__item", text: /Bar/ do |item|
        item.assert_selector "input[type='radio'][name='object_type'][value='bar']"
        item.assert_selector ".govuk-radios__label", text: "Bar"
      end

      radios.assert_selector ".govuk-radios__item", text: /Baz/ do |item|
        item.assert_selector "input[type='radio'][name='object_type'][value='baz']"
        item.assert_selector ".govuk-radios__label", text: "Baz"
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
