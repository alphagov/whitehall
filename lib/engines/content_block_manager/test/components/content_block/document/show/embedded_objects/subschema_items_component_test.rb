require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL
  include ContentBlockManager::Engine.routes.url_helpers

  let(:details) do
    {
      "embedded-type" => {
        "my-embedded-object" => {
          "title" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
        "my-other-embedded-object" => {
          "title" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:subschema) { stub("subschema", id: "embedded-type", name: "Embedded Type") }

  let(:content_block_document) { build(:content_block_document, id: SecureRandom.uuid) }
  let(:content_block_edition) { build(:content_block_edition, :pension, details:, document: content_block_document) }

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemsComponent.new(
      content_block_edition:,
      subschema:,
    )
  end

  describe "#id" do
    it "returns the sub-schema's ID" do
      assert_equal component.id, subschema.id
    end
  end

  describe "#label" do
    it "returns the sub-schema's name and count of objects" do
      assert_equal component.label, "Embedded Types (2)"
    end
  end

  describe "rendering" do
    it "renders a SummaryListComponent for each object" do
      summary_list_stub_1 = "my-embedded-object"
      summary_list_stub_2 = "my-other-embedded-object"

      ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemComponent.expects(:new).with(
        content_block_edition:,
        object_type: subschema.id,
        object_title: "my-embedded-object",
      ).returns(summary_list_stub_1)

      ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemComponent.expects(:new).with(
        content_block_edition:,
        object_type: subschema.id,
        object_title: "my-other-embedded-object",
      ).returns(summary_list_stub_2)

      component.expects(:render).with(summary_list_stub_1).returns(summary_list_stub_1)
      component.expects(:render).with(summary_list_stub_2).returns(summary_list_stub_2)
      component.expects(:render).at_least_once.with("govuk_publishing_components/components/button", anything)

      render_inline(component)

      assert_text summary_list_stub_1
      assert_text summary_list_stub_2
    end

    it "renders a button to add an object" do
      button_stub = "BUTTON"

      component.expects(:render).with("govuk_publishing_components/components/button", {
        text: "Add an embedded type",
        href: new_content_block_manager_content_block_document_embedded_object_path(
          content_block_edition.document,
          object_type: subschema.id,
        ),
        margin_bottom: 6,
      }).returns(button_stub)

      component.expects(:render).at_least_once.with(anything)

      render_inline(component)

      assert_text button_stub
    end

    describe "when show_button is set to false" do
      let(:component) do
        ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemsComponent.new(
          content_block_edition:,
          subschema:,
          show_button: false,
        )
      end

      it "does not render a button" do
        component.expects(:render).at_least_once.with(anything)
        component.expects(:render).with("govuk_publishing_components/components/button", anything).never

        render_inline(component)
      end
    end
  end
end
