require "test_helper"

class PublicationTest < EditionTestCase
  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments

  test 'should be invalid without a publication date' do
    publication = build(:publication, publication_date: nil)
    refute publication.valid?
  end

  test "should build a draft copy of the existing publication" do
    published_publication = create(:published_publication, 
      :with_attachment,
      publication_date: Date.parse("2010-01-01"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_equal published_publication.attachments, draft_publication.attachments
    assert_equal published_publication.publication_date, draft_publication.publication_date
    assert_equal published_publication.publication_type, draft_publication.publication_type
  end

  test "should allow setting of publication type" do
    publication = build(:publication, publication_type: PublicationType::PolicyPaper)
    assert publication.valid?
  end

  test "should be invalid without a publication type" do
    publication = build(:publication, publication_type: nil)
    refute publication.valid?
  end

  test "#in_chronological_order returns docs order in ascending order of publication_date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    mar = create(:publication, publication_date: Date.parse("2011-03-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Publication.in_chronological_order.all
  end

  test "#in_reverse_chronological_order returns docs order in descending order of publication_date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    mar = create(:publication, publication_date: Date.parse("2011-03-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Publication.in_reverse_chronological_order.all
  end

  test "#published_before returns editions whose publication_date is before the given date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [jan], Publication.published_before("2011-01-29").all
  end

  test "#published_after returns editions whose publication_date is after the given date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [feb], Publication.published_after("2011-01-29").all
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

  test "should find publication with title containing keyword" do
    publication_without_keyword = create(:publication, title: "title that should not be found")
    publication_with_keyword = create(:publication, title: "title containing keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("keyword")
  end

  test "should find publication with body containing keyword" do
    publication_without_keyword = create(:publication, body: "body that should not be found")
    publication_with_keyword = create(:publication, body: "body containing keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("keyword")
  end

  test "should find publications containing any of the keywords" do
    publication_with_first_keyword = create(:publication, body: "this document is about muppets")
    publication_with_second_keyword = create(:publication, body: "this document is about klingons")
    assert_equal [publication_with_first_keyword, publication_with_second_keyword], Publication.with_content_containing("klingons", "muppets")
  end

  test "should find publications containing keyword regardless of case" do
    publication_with_keyword = create(:publication, body: "body containing Keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("keyword")
  end

  test "should find publications containing keyword as part of a word" do
    publication_with_keyword = create(:publication, body: "body containing keyword in the middle")
    assert_equal [publication_with_keyword], Publication.with_content_containing("key")
  end
end
