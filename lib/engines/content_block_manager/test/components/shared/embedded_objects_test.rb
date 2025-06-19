require "test_helper"

class ContentBlockManager::Shared::EmbeddedObjectsTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
        "another-embedded-object" => {
          "name" => "Another Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:schema) { stub(:schema) }
  let(:fields) do
    [
      stub(:field, name: "field-1"),
      stub(:field, name: "field-2"),
    ]
  end
  let(:subschema) { stub(:subschema, block_type: "embedded-objects", name: "Embedded objects", fields:) }
  let(:document) { build(:content_block_document, :pension, schema:) }
  let(:content_block_edition) { build_stubbed(:content_block_edition, :pension, details:, document:) }
  let(:redirect_url) { "https://example.com" }

  let(:component) do
    ContentBlockManager::Shared::EmbeddedObjectsComponent.new(
      content_block_edition:,
      subschema:,
      redirect_url:,
    )
  end

  before do
    schema.stubs(:subschema).returns(subschema)
  end

  it "renders all embedded objects of a particular type" do
    summary_card_double = stub("summary_card")

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:with_collection).with(
      %w[my-embedded-object another-embedded-object],
      content_block_edition: content_block_edition,
      object_type: subschema.block_type,
      redirect_url:,
      test_id_prefix: "embedded",
    ).returns(summary_card_double)

    component.expects(:render).with(summary_card_double)

    render_inline(component)
  end

  it "shows a title" do
    render_inline(component)

    assert_selector "h2.govuk-heading-m", text: "Embedded Objects"
  end

  it "renders a button to add an object if the document is a new block" do
    document.expects(:is_new_block?).at_least_once.returns(true)

    render_inline(component)

    new_path = new_embedded_object_content_block_manager_content_block_edition_path(
      content_block_edition,
      object_type: subschema.block_type,
    )

    assert_selector "a.govuk-button[href='#{new_path}']", text: "Add another embedded object"
  end

  it "does not render a button to add an object if the document is not a new block" do
    document.expects(:is_new_block?).at_least_once.returns(false)

    render_inline(component)

    refute_selector "a.govuk-button", text: /embedded object/
  end

  describe "when no embedded objects are present" do
    let(:details) do
      {}
    end

    describe "when the document is a new block" do
      before do
        document.expects(:is_new_block?).at_least_once.returns(true)
      end

      it "renders the correct button text" do
        render_inline(component)

        new_path = new_embedded_object_content_block_manager_content_block_edition_path(
          content_block_edition,
          object_type: subschema.block_type,
        )

        assert_selector "a.govuk-button[href='#{new_path}']", text: "Add an embedded object"
      end

      it "shows the title" do
        render_inline(component)

        assert_selector "h2.govuk-heading-m", text: "Embedded Objects"
      end
    end

    describe "when the document is not a new block" do
      before do
        document.expects(:is_new_block?).at_least_once.returns(false)
      end

      it "does not show the title" do
        render_inline(component)

        refute_selector "h2.govuk-heading-m", text: "Embedded Objects"
      end
    end
  end
end
