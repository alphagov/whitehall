require "test_helper"

class PublicationTest < ActiveSupport::TestCase
  include DocumentBehaviour

  should_be_featurable :publication

  test 'should be invalid without a publication date' do
    publication = build(:publication, publication_date: nil)
    refute publication.valid?
  end

  test 'should be valid without ISBN' do
    publication = build(:publication, isbn: nil)
    assert publication.valid?
  end

  test 'should be valid with blank ISBN' do
    publication = build(:publication, isbn: "")
    assert publication.valid?
  end

  test 'should be invalid with ISBN but not in ISBN-10 or ISBN-13 format' do
    publication = build(:publication, isbn: "invalid-isbn")
    refute publication.valid?
  end

  test 'should be valid with ISBN in ISBN-10 format' do
    publication = build(:publication, isbn: "0261102737")
    assert publication.valid?
  end

  test 'should be valid with ISBN in ISBN-13 format' do
    publication = build(:publication, isbn: "978-0261103207")
    assert publication.valid?
  end

  test 'should be invalid with malformed order url' do
    publication = build(:publication, order_url: "invalid-url")
    refute publication.valid?
  end

  test 'should be valid with order url with HTTP protocol' do
    publication = build(:publication, order_url: "http://example.com")
    assert publication.valid?
  end

  test 'should be valid with order url with HTTPS protocol' do
    publication = build(:publication, order_url: "https://example.com")
    assert publication.valid?
  end

  test 'should be valid without order url' do
    publication = build(:publication, order_url: nil)
    assert publication.valid?
  end

  test 'should be valid with blank order url' do
    publication = build(:publication, order_url: nil)
    assert publication.valid?
  end

  test "should build a draft copy of the existing publication" do
    attachment = create(:attachment)
    published_publication = create(:published_publication,
      publication_date: Date.parse("2010-01-01"),
      unique_reference: "ABC-123",
      isbn: "0099532816",
      publication_type_id: PublicationType::ResearchAndAnalysis.id,
      order_url: "http://example.com/order-url",
      attachments: [attachment]
    )

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_equal published_publication.attachments, draft_publication.attachments
    assert_equal published_publication.publication_date, draft_publication.publication_date
    assert_equal published_publication.unique_reference, draft_publication.unique_reference
    assert_equal published_publication.isbn, draft_publication.isbn
    assert_equal published_publication.publication_type, draft_publication.publication_type
    assert_equal published_publication.order_url, draft_publication.order_url
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

    edition_attachments_attributes = publication.edition_attachments.inject({}) do |h, da|
      h[da.id] = da.attributes.merge("_destroy" => (da.attachment == attachment_1 ? "1" : "0"))
      h
    end
    publication.update_attributes(edition_attachments_attributes: edition_attachments_attributes)
    publication.reload

    assert_equal [attachment_2], publication.attachments
  end

  test "should allow setting of publication type" do
    publication = build(:publication, publication_type: PublicationType::PolicyPaper)
    assert publication.valid?
  end

  test "should be invalid without a publication type" do
    publication = build(:publication, publication_type: nil)
    refute publication.valid?
  end
end

class PublicationsInTopicsTest < ActiveSupport::TestCase
  def setup
    @policy_1 = create(:published_policy)
    @topic_1 = create(:topic, policies: [@policy_1])
    @policy_2 = create(:published_policy)
    @topic_2 = create(:topic, policies: [@policy_2])
    @draft_policy = create(:draft_policy)
    @topic_with_draft_policy = create(:topic, policies: [@draft_policy])
  end

  test "should be able to find a publication using the topic of an associated policy" do
    published_publication = create(:published_publication, related_policies: @topic_1.policies)

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
  end

  test "should return the publications with the given policy but not other policies" do
    published_publication_1 = create(:published_publication, related_policies: @topic_1.policies)
    published_publication_2 = create(:published_publication, related_policies: @topic_1.policies + @topic_2.policies)

    assert_equal [published_publication_1, published_publication_2], Publication.in_topic([@topic_1]).all
    assert_equal [published_publication_2], Publication.in_topic([@topic_2]).all
  end

  test "should ignore non-integer topic ids" do
    assert_equal [], Publication.in_topic(["'bad"]).all
  end

  test "returns publications with any of the listed topics" do
    publications = [
      create(:published_publication, related_policies: @topic_1.policies),
      create(:published_publication, related_policies: @topic_2.policies)
    ]

    assert_equal publications, Publication.in_topic([@topic_1, @topic_2]).all
  end

  test "should only find published publications, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1])
    create(:draft_publication, related_policies: [@policy_1])

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
  end

  test "should only consider associations through published policies, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1, @draft_policy])

    assert_equal [published_publication], Publication.in_topic([@topic_1]).all
    assert_equal [], Publication.in_topic([@topic_with_draft_policy]).all
  end

  test "should consider the topics of the latest published edition of a policy" do
    user = create(:departmental_editor)
    policy_1_b = @policy_1.create_draft(user)
    topic_1_b = create(:topic, policies: [policy_1_b])
    published_publication = create(:published_publication, related_policies: [policy_1_b])

    assert_equal [], Publication.in_topic([topic_1_b]).all

    policy_1_b.change_note = "test"
    assert policy_1_b.publish_as(user, force: true), "Should be able to publish"
    topic_1_b.reload
    assert_equal [published_publication], Publication.in_topic([topic_1_b]).all
  end

end
