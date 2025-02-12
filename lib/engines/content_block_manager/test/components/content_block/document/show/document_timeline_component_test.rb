require "test_helper"

class ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponentTest < ViewComponent::TestCase
  extend Minitest::Spec::DSL

  let(:user) { build_stubbed(:user) }

  it "renders components for each event" do
    item = build_stubbed(:content_block_edition, :email_address, change_note: nil, internal_change_note: nil)
    scheduled_item = build_stubbed(
      :content_block_edition,
      :email_address,
      change_note: nil,
      internal_change_note: nil,
      scheduled_publication: 2.days.from_now,
    )
    version_1 = build_stubbed(
      :content_block_version,
      event: "created",
      whodunnit: user.id,
      created_at: 4.days.ago,
      item:,
    )
    version_2 = build_stubbed(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      created_at: 3.days.ago,
      item:,
    )
    version_3 = build_stubbed(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "published",
      created_at: 2.days.ago,
      item:,
    )
    version_4 = build_stubbed(
      :content_block_version,
      event: "updated",
      whodunnit: user.id,
      state: "scheduled",
      created_at: 1.day.ago,
      item: scheduled_item,
    )
    superseded_version = build_stubbed(
      :content_block_version,
      event: "updated",
      state: "superseded",
      item:,
    )

    component = ContentBlockManager::ContentBlock::Document::Show::DocumentTimelineComponent.new(
      content_block_versions: [version_4, version_3, version_2, version_1, superseded_version],
    )

    version_2_component_stub = stub("timeline_item_component")
    version_3_component_stub = stub("timeline_item_component")
    version_4_component_stub = stub("timeline_item_component")

    ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponent
      .expects(:new)
      .with(
        version: version_4,
        is_first_published_version: false,
        is_latest: true,
      ).returns(version_4_component_stub)

    ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponent
      .expects(:new)
      .with(
        version: version_3,
        is_first_published_version: false,
        is_latest: false,
      ).returns(version_3_component_stub)

    ContentBlockManager::ContentBlock::Document::Show::DocumentTimeline::TimelineItemComponent
      .expects(:new)
      .with(
        version: version_2,
        is_first_published_version: true,
        is_latest: false,
      ).returns(version_2_component_stub)

    component.expects(:render).with(version_4_component_stub).returns("version 4")
    component.expects(:render).with(version_3_component_stub).returns("version 3")
    component.expects(:render).with(version_2_component_stub).returns("version 2")

    render_inline component

    assert_text "version 4\n    version 3\n    version 2"
  end
end
