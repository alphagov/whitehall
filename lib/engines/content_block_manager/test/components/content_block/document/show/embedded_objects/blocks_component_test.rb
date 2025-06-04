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

  let(:content_block_edition) { build(:content_block_edition, :pension) }
  let(:content_block_document) { build(:content_block_document, :pension) }

  let(:schema) { stub("schema") }
  let(:subschema) { stub("schema", embeddable_as_block?: embeddable_as_block) }

  before do
    content_block_document.stubs(:schema).returns(schema)
    content_block_document.stubs(:latest_edition).returns(content_block_edition)
    schema.stubs(:subschema).with(object_type).returns(subschema)
  end

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::BlocksComponent.new(
      items:,
      object_type:,
      object_title:,
      content_block_document:,
    )
  end

  describe "when the block type is not embeddable as a block" do
    let(:embeddable_as_block) { false }

    it "renders a summary card" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-list__row", count: 2

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

    it "adds the correct class to the wrapper" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component"
      refute_selector ".app-c-embedded-objects-blocks-component.app-c-embedded-objects-blocks-component--with-block"
    end

    it "does not render the details" do
      render_inline component

      refute_selector ".app-c-embedded-objects-blocks-component__details-wrapper"
    end
  end

  describe "when the block type is embeddable as a block" do
    let(:embeddable_as_block) { true }

    before do
      content_block_edition.expects(:render).with(
        content_block_document.embed_code_for_field("#{object_type}/#{object_title}"),
      ).returns("BLOCK_RESPONSE")
    end

    it "returns the block inside the summary card" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component .govuk-summary-card" do |wrapper|
        wrapper.assert_selector ".govuk-summary-list__row", count: 1
        wrapper.assert_selector ".govuk-summary-list__row[data-testid='else']" do |row|
          row.assert_selector ".govuk-summary-list__key", text: "Something"
          row.assert_selector ".govuk-summary-list__value" do |col|
            col.assert_selector ".app-c-embedded-objects-blocks-component__content", text: "BLOCK_RESPONSE"
            col.assert_selector ".app-c-embedded-objects-blocks-component__embed-code", text: content_block_document.embed_code_for_field("#{object_type}/#{object_title}")
          end
        end
      end
    end

    it "shows the details component with the attributes in a summary list" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component__details-wrapper" do |wrapper|
        wrapper.assert_selector ".govuk-details__summary-text", text: "All #{object_type} attributes"
        wrapper.assert_selector ".govuk-details__text", visible: false do |details|
          details.assert_selector ".app-c-embedded-objects-blocks-component__details-text",
                                  text: "These are all the #{object_type} attributes that make up the #{object_type}. You can use the embed code for each attribute separately in your content if required.",
                                  visible: false

          details.assert_selector ".app-c-embedded-objects-blocks-component__details-summary-list", visible: false do |summary_list|
            summary_list.assert_selector ".govuk-summary-list__row", count: 2, visible: false

            summary_list.assert_selector ".govuk-summary-list__row[data-testid='else_foo']", visible: false do |row|
              row.assert_selector ".govuk-summary-list__key", text: "Foo", visible: false

              row.assert_selector ".govuk-summary-list__value", visible: false do |col|
                col.assert_selector ".app-c-embedded-objects-blocks-component__content", text: "bar", visible: false
                col.assert_selector ".app-c-embedded-objects-blocks-component__embed-code", text: content_block_document.embed_code_for_field("#{object_type}/#{object_title}/foo"), visible: false
              end
            end

            summary_list.assert_selector ".govuk-summary-list__row[data-testid='else_fizz']", visible: false do |row|
              row.assert_selector ".govuk-summary-list__key", text: "Fizz", visible: false

              row.assert_selector ".govuk-summary-list__value", visible: false do |col|
                col.assert_selector ".app-c-embedded-objects-blocks-component__content", text: "buzz", visible: false
                col.assert_selector ".app-c-embedded-objects-blocks-component__embed-code", text: content_block_document.embed_code_for_field("#{object_type}/#{object_title}/fizz"), visible: false
              end
            end
          end
        end
      end
    end

    it "adds the correct class to the wrapper" do
      render_inline component

      assert_selector ".app-c-embedded-objects-blocks-component.app-c-embedded-objects-blocks-component--with-block"
    end
  end
end
