require "test_helper"

class PublicationTest < EditionTestCase
  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_allow_referencing_of_statistical_data_sets
  should_allow_a_summary_to_be_written
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note

  test 'should be invalid without a publication date' do
    publication = build(:publication, publication_date: nil)
    refute publication.valid?
  end

  test 'imported publications are valid when the publication_type is \'imported-awaiting-type\'' do
    publication = build(:publication, state: 'imported', publication_type: PublicationType.find_by_slug('imported-awaiting-type'))
    assert publication.valid?
  end

  test 'imported publications are not valid_as_draft? when the publcation_type is \'imported-awaiting-type\'' do
    publication = build(:publication, state: 'imported', publication_type: PublicationType.find_by_slug('imported-awaiting-type'))
    refute publication.valid_as_draft?
  end

  [:draft, :scheduled, :published, :archived, :submitted, :rejected].each do |state|
    test "#{state} editions are not valid when the publication type is 'imported-awaiting-type'" do
      edition = build(:publication, state: state, publication_type: PublicationType.find_by_slug('imported-awaiting-type'))
      refute edition.valid?
    end
  end

  test "should build a draft copy of the existing publication" do
    published_publication = create(:published_publication,
      :with_attachment,
      publication_date: Date.parse("2010-01-01"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_not_equal published_publication.attachments, draft_publication.attachments
    assert_equal published_publication.attachments.first.attachment_data, draft_publication.attachments.first.attachment_data
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

  test ".in_chronological_order returns publications in ascending order of publication_date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    mar = create(:publication, publication_date: Date.parse("2011-03-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Publication.in_chronological_order.all
  end

  test ".in_reverse_chronological_order returns publications in descending order of publication_date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    mar = create(:publication, publication_date: Date.parse("2011-03-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Publication.in_reverse_chronological_order.all
  end

  test ".published_before returns editions whose publication_date is before the given date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [jan], Publication.published_before("2011-01-29").all
  end

  test ".published_after returns editions whose publication_date is after the given date" do
    jan = create(:publication, publication_date: Date.parse("2011-01-01"))
    feb = create(:publication, publication_date: Date.parse("2011-02-01"))
    assert_equal [feb], Publication.published_after("2011-01-29").all
  end

  test "access_limited flag is ignored for non-stats types" do
    e = build(:draft_publication, publication_type: PublicationType::PolicyPaper, access_limited: true)
    refute e.access_limited?
  end

  test "persisted value of access_limited flag is nil for non-stats types" do
    e = create(:draft_publication, publication_type: PublicationType::PolicyPaper, access_limited: true)
    assert e.reload.read_attribute(:access_limited).nil?
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

    assert_equal [published_publication], Publication.published_in_topic([@topic_1]).all
  end

  test "should return the publications with the given policy but not other policies" do
    published_publication_1 = create(:published_publication, related_policies: @topic_1.policies)
    published_publication_2 = create(:published_publication, related_policies: @topic_1.policies + @topic_2.policies)

    assert_equal [published_publication_1, published_publication_2], Publication.published_in_topic([@topic_1]).all
    assert_equal [published_publication_2], Publication.published_in_topic([@topic_2]).all
  end

  test "should ignore non-integer topic ids" do
    assert_equal [], Publication.published_in_topic(["'bad"]).all
  end

  test "returns publications with any of the listed topics" do
    publications = [
      create(:published_publication, related_policies: @topic_1.policies),
      create(:published_publication, related_policies: @topic_2.policies)
    ]

    assert_equal publications, Publication.published_in_topic([@topic_1, @topic_2]).all
  end

  test "should only find published publications, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1])
    create(:draft_publication, related_policies: [@policy_1])

    assert_equal [published_publication], Publication.published_in_topic([@topic_1]).all
  end

  test "should only consider associations through published policies, not draft ones" do
    published_publication = create(:published_publication, related_policies: [@policy_1, @draft_policy])

    assert_equal [published_publication], Publication.published_in_topic([@topic_1]).all
    assert_equal [], Publication.published_in_topic([@topic_with_draft_policy]).all
  end

  test "should consider the topics of the latest published edition of a policy" do
    user = create(:departmental_editor)
    policy_1_b = @policy_1.create_draft(user)
    policy_1_b.change_note = 'change-note'
    topic_1_b = create(:topic, policies: [policy_1_b])
    published_publication = create(:published_publication, related_policies: [policy_1_b])

    assert_equal [], Publication.published_in_topic([topic_1_b]).all

    policy_1_b.change_note = "test"
    assert policy_1_b.publish_as(user, force: true), "Should be able to publish"
    topic_1_b.reload
    assert_equal [published_publication], Publication.published_in_topic([topic_1_b]).all
  end

  test "should be able to get items scheduled in a particular topic" do
    scheduled_publication = create(:scheduled_publication, related_policies: [@policy_1])
    create(:published_publication, related_policies: [@policy_1])

    assert_equal [scheduled_publication], Publication.scheduled_in_topic([@topic_1]).all
  end
end
