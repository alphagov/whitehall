require "test_helper"
require Rails.root.join("db/migrate/20120821091308_strip_inline_attachments_from_publications_and_consultations.rb")

class StripInlineAttachmentsFromPublicationsAndConsultationsTest < ActiveSupport::TestCase
  test "migration removes inline attachment tags from publication" do
    create(:published_publication, body: %Q{First para\r\n\r\nSecond para\n\n!@1})
    StripInlineAttachmentsFromPublicationsAndConsultations.new.up
    assert_equal 1, Publication.count
    assert_equal %Q{First para\r\n\r\nSecond para}, Publication.first.body
  end

  test "migration removes multiple inline attachment tags from publication" do
    create(:published_publication, body: %Q{First para\r\n\r\nSecond para\n\n!@1\n\n!@2\n\nThird para})
    StripInlineAttachmentsFromPublicationsAndConsultations.new.up
    assert_equal 1, Publication.count
    assert_equal %Q{First para\r\n\r\nSecond para\n\nThird para}, Publication.first.body
  end

  test "migration removes trailing newlines" do
    create(:published_publication, body: %Q{First para\r\n\r\nSecond para\n\n!@1\n\n\n\n})
    StripInlineAttachmentsFromPublicationsAndConsultations.new.up
    assert_equal 1, Publication.count
    assert_equal %Q{First para\r\n\r\nSecond para}, Publication.first.body
  end

  test "migration removes inline attachment tags from draft publication" do
    create(:draft_publication, body: %Q{First para\r\n\r\nSecond para\n\n!@1\n\n})
    StripInlineAttachmentsFromPublicationsAndConsultations.new.up
    assert_equal 1, Publication.count
    assert_equal %Q{First para\r\n\r\nSecond para}, Publication.first.body
  end

  test "migration removes inline attachment tags from consultation" do
    create(:published_consultation, body: %Q{First para\r\n\r\nSecond para\n\n!@1\n\n})
    StripInlineAttachmentsFromPublicationsAndConsultations.new.up
    assert_equal 1, Consultation.count
    assert_equal %Q{First para\r\n\r\nSecond para}, Consultation.first.body
  end
end
