require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end

  let(:object_type) { "telephone" }

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent.new(
      items:,
      object_type:,
    )
  end

  it "renders a summary list with the expected attributes" do
    component.expects(:render).with(
      "govuk_publishing_components/components/summary_list", {
        items: [
          {
            field: "Foo",
            value: "bar",
          },
          {
            field: "Fizz",
            value: "buzz",
          },
        ],
      }
    ).returns("STUB_RESPONSE")

    render_inline component

    assert_text "STUB_RESPONSE"
  end

  describe "when there is a translated field label" do
    it "uses translated label" do
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.foo", default: "Foo").returns("Foo translated")
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.fizz", default: "Fizz").returns("Fizz translated")

      I18n.expects(:t).with("content_block_edition.details.values.bar", default: "bar").returns("bar")
      I18n.expects(:t).with("content_block_edition.details.values.buzz", default: "buzz").returns("buzz")

      component.expects(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo translated",
              value: "bar",
            },
            {
              field: "Fizz translated",
              value: "buzz",
            },
          ],
        }
      ).returns("STUB_RESPONSE")

      render_inline component

      assert_text "STUB_RESPONSE"
    end
  end

  describe "when there is a translated field value" do
    it "uses translated label" do
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.foo", default: "Foo").returns("Foo")
      I18n.expects(:t).with("content_block_edition.details.labels.telephone.fizz", default: "Fizz").returns("Fizz")

      I18n.expects(:t).with("content_block_edition.details.values.bar", default: "bar").returns("Bar translated")
      I18n.expects(:t).with("content_block_edition.details.values.buzz", default: "buzz").returns("Buzz translated")

      component.expects(:render).with(
        "govuk_publishing_components/components/summary_list", {
          items: [
            {
              field: "Foo",
              value: "Bar translated",
            },
            {
              field: "Fizz",
              value: "Buzz translated",
            },
          ],
        }
      ).returns("STUB_RESPONSE")

      render_inline component

      assert_text "STUB_RESPONSE"
    end
  end
end
