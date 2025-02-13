require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardsComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:details) do
    {
      "embedded-objects" => {
        "my-embedded-object" => {
          "name" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
        "my-other-embedded-object" => {
          "name" => "My Embedded Object",
          "field-1" => "Value 1",
          "field-2" => "Value 2",
        },
      },
    }
  end

  let(:content_block_edition) { build(:content_block_edition, :email_address, details:) }
  let(:content_block_document) { build(:content_block_document) }

  before do
    content_block_document.latest_edition = content_block_edition
  end

  it "should render a summary card for each embedded object" do
    object1_double = stub("summary_card_1")
    object2_double = stub("summary_card_2")

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-embedded-object",
    ).returns(object1_double)

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).with(
      content_block_edition:,
      object_type: "embedded-objects",
      object_name: "my-other-embedded-object",
    ).returns(object2_double)

    component = ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardsComponent.new(
      content_block_document:,
      object_type: "embedded-objects",
    )

    component.expects(:render).with(object1_double)
    component.expects(:render).with(object2_double)

    render_inline(component)
  end

  it "does not render any cards when there are no embedded objects of a particular type" do
    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:new).never

    render_inline ContentBlockManager::ContentBlock::Document::Show::EmbeddedObjects::SummaryCardsComponent.new(
      content_block_document:,
      object_type: "something-else",
    )
  end
end
