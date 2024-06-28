require "test_helper"

class ContentObjectStore::ContentBlockEditionTest < ActiveSupport::TestCase
  test "content_block_edition exists with required data" do
    content_block_document = create(:content_block_document)
    content_block_edition = create(
      :content_block_edition,
      content_block_document_id: content_block_document.id,
      created_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      updated_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      details: '{ "some_field": "some_content" }',
    )

    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_edition.created_at
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_edition.updated_at
    assert_equal '{ "some_field": "some_content" }', content_block_edition.details
  end
end
