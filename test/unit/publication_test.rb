require "test_helper"

class PublicationTest < ActiveSupport::TestCase

  test "should be valid when built from the factory" do
    publication = build(:publication)
    assert publication.valid?
  end

  test "should build a draft copy of the existing publication" do
    attachment = create(:attachment)
    published_publication = create(:published_publication, attachments: [attachment])

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_equal published_publication.attachments, draft_publication.attachments
  end

  test "allows attachment" do
    assert build(:publication).allows_attachments?
  end

  test "should allow multiple attachments" do
    attachment_1 = create(:attachment)
    attachment_2 = create(:attachment)

    publication = create(:publication, attachments: [attachment_1, attachment_2])

    assert_equal [attachment_1, attachment_2], publication.attachments
  end

  test "should allow deletion of attachments via nested attributes" do
    attachment_1 = create(:attachment)
    attachment_2 = create(:attachment)

    publication = create(:publication, attachments: [attachment_1, attachment_2])

    document_attachments_attributes = publication.document_attachments.inject({}) do |h, da|
      h[da.id] = da.attributes.merge("_destroy" => (da.attachment == attachment_1 ? "1" : "0"))
      h
    end
    publication.update_attributes(document_attachments_attributes: document_attachments_attributes)
    publication.reload

    assert_equal [attachment_2], publication.attachments
  end

  test "should build a draft copy with copy of publication metadatum" do
    metadatum = create(:publication_metadatum)
    published_publication = create(:published_publication, publication_metadatum: metadatum)
    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert draft_publication.valid?

    assert new_metadatum = draft_publication.publication_metadatum
    refute_equal metadatum, new_metadatum
    assert_equal metadatum.publication_date, new_metadatum.publication_date
  end
end