require "test_helper"

class ContentBlockManager::WorkflowTest < ActiveSupport::TestCase
  test "draft is the default state" do
    edition = create(:content_block_edition, document: create(:content_block_document, block_type: "email_address"))
    assert edition.draft?
  end

  test "publishing a draft edition transitions it into the published state" do
    edition = create(:content_block_edition, document: create(:content_block_document, block_type: "email_address"))
    edition.publish!
    assert edition.published?
  end

  test "publishing a scheduled edition transitions it into the published state" do
    edition = create(:content_block_edition,
                     document: create(
                       :content_block_document,
                       block_type: "email_address",
                     ),
                     scheduled_publication: 7.days.since(Time.zone.now).to_date,
                     state: "scheduled")
    edition.publish!
    assert edition.published?
  end

  test "scheduling an edition transitions it into the scheduled state" do
    edition = create(:content_block_edition,
                     scheduled_publication: 7.days.since(Time.zone.now).to_date,
                     document: create(
                       :content_block_document,
                       block_type: "email_address",
                     ))
    edition.schedule!
    assert edition.scheduled?
  end
end
