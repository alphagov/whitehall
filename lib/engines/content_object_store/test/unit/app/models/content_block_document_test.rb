require "test_helper"

class ContentObjectStore::ContentBlockDocumentTest < ActiveSupport::TestCase
  test "content_block_document exists with required data" do
    content_block_document = create(
      :content_block_document,
      content_id: "52084b2d-4a52-4e69-ba91-3052b07c7eb6",
      title: "Title",
      block_type: "Type",
      created_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
      updated_at: Time.zone.local(2000, 12, 31, 23, 59, 59).utc,
    )

    assert_equal "52084b2d-4a52-4e69-ba91-3052b07c7eb6", content_block_document.content_id
    assert_equal "Title", content_block_document.title
    assert_equal "Type", content_block_document.block_type
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.created_at
    assert_equal Time.zone.local(2000, 12, 31, 23, 59, 59).utc, content_block_document.updated_at
  end

  test "it does not allow the block type to be changed" do
    content_block_document = create(:content_block_document)

    assert_raise ActiveRecord::ReadonlyAttributeError do
      content_block_document.update(block_type: "something_else")
    end
  end
end
