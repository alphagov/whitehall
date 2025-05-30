require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:details) do
    {
      "embedded-type-1" => {
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
      "embedded-type-2" => {
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

  let(:subschema_1) { stub("subschema_1") }
  let(:subschema_2) { stub("subschema_2") }

  let(:subschemas) do
    [
      subschema_1,
      subschema_2,
    ]
  end

  let(:content_block_document) { build(:content_block_document, id: SecureRandom.uuid) }
  let(:content_block_edition) { build(:content_block_edition, :pension, details:, document: content_block_document) }

  before do
    content_block_document.latest_edition = content_block_edition
    subschema_1.stubs(:id).returns("embedded-type-1")
    subschema_2.stubs(:id).returns("embedded-type-2")
    subschema_1.stubs(:name).returns("embedded type 1")
    subschema_2.stubs(:name).returns("embedded type 2")
  end

  it "should render content for each embedded object" do
    object1_double = "<p>content_1</p>"
    object2_double = "<p>content_2</p>"
    object3_double = "<p>content_2</p>"
    object4_double = "<p>content_2</p>"

    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabContentComponent.expects(:new).with(
      content_block_edition:,
      object_type: "embedded-type-1",
      object_title: "my-embedded-object",
    ).returns(object1_double)

    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabContentComponent.expects(:new).with(
      content_block_edition:,
      object_type: "embedded-type-1",
      object_title: "my-other-embedded-object",
    ).returns(object2_double)

    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabContentComponent.expects(:new).with(
      content_block_edition:,
      object_type: "embedded-type-2",
      object_title: "my-embedded-object",
    ).returns(object3_double)

    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabContentComponent.expects(:new).with(
      content_block_edition:,
      object_type: "embedded-type-2",
      object_title: "my-other-embedded-object",
    ).returns(object4_double)

    component = ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabComponent.new(
      content_block_document:,
      subschemas:,
    )

    expected_items = {
      tabs: [
        {
          id: "embedded-type-1",
          label: "embedded type 1s (2)",
          content: "button#{object1_double}#{object2_double}",
        },
        {
          id: "embedded-type-2",
          label: "embedded type 2s (2)",
          content: "button#{object3_double}#{object4_double}",
        },
      ],
    }

    expected_button_args_1 = {
      text: "Add an embedded type 1",
      href: "/content-block-manager/content-block/#{content_block_document.id}/embedded_objects/embedded-type-1/new",
      margin_bottom: 6,
    }

    expected_button_args_2 = {
      text: "Add an embedded type 2",
      href: "/content-block-manager/content-block/#{content_block_document.id}/embedded_objects/embedded-type-2/new",
      margin_bottom: 6,
    }

    component.expects(:render).with("govuk_publishing_components/components/button", expected_button_args_1).returns("button")
    component.expects(:render).with(object1_double).returns(object1_double)
    component.expects(:render).with(object2_double).returns(object2_double)
    component.expects(:render).with("govuk_publishing_components/components/button", expected_button_args_2).returns("button")
    component.expects(:render).with(object3_double).returns(object3_double)
    component.expects(:render).with(object4_double).returns(object4_double)
    component.expects(:render).with("govuk_publishing_components/components/tabs", expected_items).returns(object4_double)

    render_inline(component)
  end

  it "does not render any content when there are no embedded objects" do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabContentComponent.expects(:new).never

    edition_with_no_data = build(:content_block_edition, :pension, details: {})
    content_block_document.latest_edition = edition_with_no_data

    render_inline ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::TabComponent.new(
      content_block_document:,
      subschemas:,
    )
  end
end
