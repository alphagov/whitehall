require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent.new(
      items:,
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
end
