require "test_helper"

class ContentObjectStore::WorkflowTest < ActiveSupport::TestCase
  test "draft is the default state" do
    edition = create(:content_block_edition, document: create(:content_block_document, block_type: "email_address"))
    assert edition.draft?
  end

  test "publishing a draft edition transitions it into the published state" do
    edition = create(:content_block_edition, document: create(:content_block_document, block_type: "email_address"))
    edition.publish!
    assert edition.published?
  end
end
