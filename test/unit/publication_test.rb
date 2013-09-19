require "test_helper"

class PublicationTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_allow_referencing_of_statistical_data_sets
  should_protect_against_xss_and_content_attacks_on :title, :body, :summary, :change_note
  should_allow_html_version

  def draft_with_new_title(edition, new_title)
    edition.create_draft(create(:author)).tap do |draft|
      draft.html_version.title = new_title
      draft.minor_change = true
      draft.publish!
    end
  end

  test 'slug of html version does not change when we republish several times' do
    publication = create(:published_publication)
    initial_slug = publication.html_version.slug

    new_draft = draft_with_new_title(publication, 'Title changed once')
    assert_equal initial_slug, new_draft.reload.html_version.slug

    further_draft = draft_with_new_title(new_draft, "Title changed again")
    assert_equal initial_slug, further_draft.reload.html_version.slug
  end

  test 'slug of html version changes whilst in draft' do
    publication = build(:draft_publication)
    publication.html_version.title = "title"
    publication.save!
    assert_equal 'title', publication.html_version.slug

    publication.html_version.title = 'new title'
    publication.save!
    assert_equal 'new-title', publication.reload.html_version.slug
  end

  test 'imported publications are valid when the publication_type is \'imported-awaiting-type\'' do
    publication = build(:publication, state: 'imported', publication_type: PublicationType.find_by_slug('imported-awaiting-type'))
    assert publication.valid?
  end

  test 'imported publications are not valid_as_draft? when the publcation_type is \'imported-awaiting-type\'' do
    publication = build(:publication, state: 'imported', publication_type: PublicationType.find_by_slug('imported-awaiting-type'))
    refute publication.valid_as_draft?
  end

  test 'imported publications are not valid_as_draft? if the first_published_at timestamp is blank' do
    publication = build(:publication, state: 'imported', first_published_at: nil)
    refute publication.valid_as_draft?
  end

  %w(submitted scheduled published).each do |state|
    test "A #{state} publication is not valid without an attachment" do
      publication = build("#{state}_publication", html_version: nil, attachments: [])
      refute publication.valid?
      assert_match /cannot be #{state} without an attachment/, publication.errors[:base].first
    end
  end

  test "should build a draft copy of the existing publication" do
    published_publication = create(:published_publication,
      :with_attachment,
      first_published_at: Date.parse("2010-01-01"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id
    )

    draft_publication = published_publication.create_draft(create(:policy_writer))

    assert_kind_of Attachment, published_publication.attachments.first
    assert_not_equal published_publication.attachments, draft_publication.attachments
    assert_equal published_publication.attachments.first.attachment_data, draft_publication.attachments.first.attachment_data
    assert_equal published_publication.first_published_at, draft_publication.first_published_at
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

  test 'archived publications are valid with the "unknown" publication_type' do
    publication = build(:archived_publication, publication_type: PublicationType::Unknown)
    assert publication.valid?
  end

  test ".in_chronological_order returns publications in ascending order of first_published_at" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    mar = create(:publication, first_published_at: Date.parse("2011-03-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Publication.in_chronological_order.all
  end

  test ".in_reverse_chronological_order returns publications in descending order of first_published_at" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    mar = create(:publication, first_published_at: Date.parse("2011-03-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Publication.in_reverse_chronological_order.all
  end

  test ".published_before returns editions whose first_published_at is before the given date" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan], Publication.published_before("2011-01-29").all
  end

  test ".published_after returns editions whose first_published_at is after the given date" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [feb], Publication.published_after("2011-01-29").all
  end

  test "new instances are access_limited based on their publication_type" do
    limit_by_default, dont_limit_by_default = PublicationType.all.partition {|pt| pt.access_limited_by_default? }.map {|pts| pts.first }
    e = build(:draft_publication, publication_type: limit_by_default)
    assert e.access_limited?
    e = build(:draft_publication, publication_type: dont_limit_by_default)
    refute e.access_limited?
  end

  test "new instances respect local access_limited over their publication_type" do
    limit_by_default, dont_limit_by_default = PublicationType.all.partition {|pt| pt.access_limited_by_default? }.map {|pts| pts.first }
    e = build(:draft_publication, publication_type: limit_by_default, access_limited: false)
    refute e.access_limited?
    e = build(:draft_publication, publication_type: dont_limit_by_default, access_limited: true)
    assert e.access_limited?
  end

  test 'existing instances don\'t change access_limit when their publication_type does' do
    limit_by_default, dont_limit_by_default = PublicationType.all.partition {|pt| pt.access_limited_by_default? }.map {|pts| pts.first }
    e = create(:draft_publication, access_limited: false)
    e.publication_type = limit_by_default
    refute e.access_limited?
    e = create(:draft_publication, access_limited: true)
    e.publication_type = dont_limit_by_default
    assert e.access_limited?
  end

  test "should be translatable" do
    publication = build(:draft_publication)
    assert publication.translatable?
  end

  test "is not translatable when non-English" do
    refute build(:publication, locale: :es).translatable?
  end

  test "can associate publications with topical events" do
    publication = create(:publication)
    assert publication.can_be_associated_with_topical_events?
    assert topical_event = publication.topical_events.create(name: "Test", description: "Test")
    assert_equal [publication], topical_event.publications
  end

end

class PublicationsInTopicsTest < ActiveSupport::TestCase
  def setup
    @topic_1 = create(:topic)
    @topic_2 = create(:topic)
  end

  test "should be able to find a publication from an associated topic" do
    published_publication = create(:published_publication, topics: [@topic_1])

    assert_equal [published_publication], Publication.published_in_topic([@topic_1]).all
  end

  test "should ignore non-integer topic ids" do
    assert_equal [], Publication.published_in_topic(["'bad"]).all
  end

  test "returns publications with any of the listed topics" do
    publications = [
      create(:published_publication, topics: [@topic_1]),
      create(:published_publication, topics: [@topic_2])
    ]

    assert_equal publications, Publication.published_in_topic([@topic_1, @topic_2]).all
  end

  test "should only find published publications, not draft ones" do
    published_publication = create(:published_publication, topics: [@topic_1])
    create(:draft_publication, topics: [@topic_1])

    assert_equal [published_publication], Publication.published_in_topic([@topic_1]).all
  end

  test "should be able to get items scheduled in a particular topic" do
    scheduled_publication = create(:scheduled_publication, topics: [@topic_1])

    assert_equal [scheduled_publication], Publication.scheduled_in_topic([@topic_1]).all
  end

  test 'search_format_types tags the publication as a publication' do
    publication = build(:publication)
    assert publication.search_format_types.include?('publication')
  end

  test 'search_format_types includes search_format_types of the publication_type' do
    publication_type = mock
    publication_type.responds_like(SpeechType.new)
    publication_type.stubs(:search_format_types).returns (['stuff-innit', 'other-thing'])
    publication = build(:publication)
    publication.stubs(:publication_type).returns(publication_type)
    assert publication.search_format_types.include?('stuff-innit')
    assert publication.search_format_types.include?('other-thing')
  end
end
