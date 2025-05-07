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
  let(:subschema) { stub(:subschema, block_type: "embedded-objects", name: "Embedded objects") }
  let(:document) { build(:content_block_document, :email_address, schema:) }
  let(:content_block_edition) { build_stubbed(:content_block_edition, :email_address, details:, document:) }
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
    object1_double = stub("summary_card_1")
    object2_double = stub("summary_card_2")

    default_args = {
      content_block_edition: content_block_edition,
      object_type: subschema.block_type,
      is_editable: true,
      redirect_url:,
    }

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      **default_args.merge(object_title: "my-embedded-object"),
    ).returns(object1_double)

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      **default_args.merge(object_title: "another-embedded-object"),
    ).returns(object2_double)

    component.expects(:render).with(object1_double)
    component.expects(:render).with(object2_double)

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

    it "renders the correct button text if the document is a new block" do
      document.expects(:is_new_block?).at_least_once.returns(true)

      render_inline(component)

      new_path = new_embedded_object_content_block_manager_content_block_edition_path(
        content_block_edition,
        object_type: subschema.block_type,
      )

      assert_selector "a.govuk-button[href='#{new_path}']", text: "Add an embedded object"
    end
  end
end
