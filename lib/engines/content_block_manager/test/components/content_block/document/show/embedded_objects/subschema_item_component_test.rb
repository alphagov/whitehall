require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:schema) { stub("schema") }
  let(:subschema) { stub("schema") }

  let(:details) do
    {
      "object": {
        "something": {
          "title": "Some title",
          "embeddable_item_1": "Foo",
          "embeddable_item_2": "Bar",
          "something_else": "",
        },
      },
    }
  end

  let(:content_block_edition) { build(:content_block_edition, :pension, details:) }
  let(:object_type) { "object" }
  let(:object_title) { "something" }

  let(:component) do
    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SubschemaItemComponent.new(
      content_block_edition:,
      object_type:,
      object_title:,
    )
  end

  before do
    content_block_edition.document.stubs(:schema).returns(schema)
    schema.stubs(:subschema).with(object_type).returns(subschema)
    subschema.stubs(:embeddable_fields).returns(%w[embeddable_item_1 embeddable_item_2 something_else])
    subschema.stubs(:field_ordering_rule).with("embeddable_item_1").returns(2)
    subschema.stubs(:field_ordering_rule).with("embeddable_item_2").returns(1)
  end

  it "renders the metadata and block components" do
    metadata_response = "METADATA"
    block_response = "BLOCKS"

    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::MetadataComponent.expects(:new).with(
      items: { "title" => "Some title" },
    ).returns(metadata_response)

    ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::BlocksComponent.expects(:new).with(
      items: { "embeddable_item_2" => "Bar", "embeddable_item_1" => "Foo" },
      object_type:,
      object_title:,
      content_block_document: content_block_edition.document,
    ).returns(block_response)

    component.expects(:render).with(metadata_response).returns(metadata_response)
    component.expects(:render).with(block_response).returns(block_response)

    render_inline component

    assert_text metadata_response
    assert_text block_response
  end
end
