require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::BlocksComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:items) do
    {
      "foo" => "bar",
      "fizz" => "buzz",
    }
  end
  let(:object_type) { "something" }
  let(:object_title) { "else" }

  let(:content_block_document) { build(:content_block_document, :pension) }

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::BlocksComponent.new(
      items:,
      object_type:,
      object_title:,
      content_block_document:,
    )
  end

  it "renders a summary card" do
    render_inline component

    assert_selector ".app-c-embedded-objects-blocks-component [data-testid='else_foo']" do |row|
      row.assert_selector ".govuk-summary-list__key", text: "Foo"
      row.assert_selector ".govuk-summary-list__value" do |col|
        col.assert_selector ".app-c-embedded-objects-blocks-component__content", text: "bar"
        col.assert_selector ".app-c-embedded-objects-blocks-component__embed-code", text: content_block_document.embed_code_for_field("#{object_type}/#{object_title}/foo")
      end
    end

    assert_selector ".app-c-embedded-objects-blocks-component [data-testid='else_fizz']" do |row|
      row.assert_selector ".govuk-summary-list__key", text: "Fizz"
      row.assert_selector ".govuk-summary-list__value" do |col|
        col.assert_selector ".app-c-embedded-objects-blocks-component__content", text: "buzz"
        col.assert_selector ".app-c-embedded-objects-blocks-component__embed-code", text: content_block_document.embed_code_for_field("#{object_type}/#{object_title}/fizz")
      end
    end
  end
end
