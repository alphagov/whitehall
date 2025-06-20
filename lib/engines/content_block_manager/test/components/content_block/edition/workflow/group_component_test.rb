require "test_helper"

class ContentBlockManager::ContentBlockEdition::Workflow::GroupComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:details) do
    {
      "embedded-type-1" => {
        "embedded-type-1-item-1" => {},
        "embedded-type-1-item-2" => {},
      },
      "embedded-type-2" => {
        "embedded-type-2-item-1" => {},
        "embedded-type-2-item-2" => {},
        "embedded-type-2-item-3" => {},
      },
      "embedded-type-3" => {},
    }
  end
  let(:content_block_edition) { build(:content_block_edition, :pension, details:) }

  let(:subschema_1) { stub("subschema_1", id: "embedded-type-1", block_type: "embedded-type-1", name: "embedded type 1", group_order: 1) }
  let(:subschema_2) { stub("subschema_2", id: "embedded-type-1", block_type: "embedded-type-2", name: "embedded type 2", group_order: 0) }
  let(:subschema_3) { stub("subschema_3", id: "embedded-type-3", block_type: "embedded-type-3", name: "embedded type 3", group_order: 2) }

  let(:subschemas) do
    [
      subschema_1,
      subschema_2,
      subschema_3,
    ]
  end

  let(:component) do
    ContentBlockManager::ContentBlockEdition::Workflow::GroupComponent.new(
      content_block_edition:,
      subschemas:,
    )
  end

  let(:request) { stub(:request, fullpath: "/foo/bar") }

  before do
    component.stubs(:request).returns(request)
  end

  it "should render a tab for each subschema that has content" do
    summary_card_stub_1 = stub("SummaryCard")
    summary_card_stub_2 = stub("SummaryCard")

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:with_collection).with(
      %w[embedded-type-1-item-1 embedded-type-1-item-2],
      content_block_edition: content_block_edition,
      object_type: subschema_1.block_type,
      redirect_url: request.fullpath,
    ).returns(summary_card_stub_1)

    ContentBlockManager::Shared::EmbeddedObjects::SummaryCardComponent.expects(:with_collection).with(
      %w[embedded-type-2-item-1 embedded-type-2-item-2 embedded-type-2-item-3],
      content_block_edition: content_block_edition,
      object_type: subschema_2.block_type,
      redirect_url: request.fullpath,
    ).returns(summary_card_stub_2)

    component.expects(:render).with(summary_card_stub_1).returns("summary_card_1_body")
    component.expects(:render).with(summary_card_stub_2).returns("summary_card_2_body")

    component.expects(:render).with("govuk_publishing_components/components/tabs", {
      tabs: [
        {
          id: subschema_2.id,
          label: "#{subschema_2.name.titleize} (3)",
          content: "summary_card_2_body",
        },
        {
          id: subschema_1.id,
          label: "#{subschema_1.name.titleize} (2)",
          content: "summary_card_1_body",
        },
      ],
    })

    render_inline component
  end
end
