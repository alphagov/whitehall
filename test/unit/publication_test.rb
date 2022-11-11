require "test_helper"

class PublicationTest < ActiveSupport::TestCase
  should_allow_image_attachments
  should_be_attachable
  should_not_allow_inline_attachments
  should_allow_referencing_of_statistical_data_sets
  should_protect_against_xss_and_content_attacks_on :publication, :title, :body, :summary, :change_note
  should_allow_external_attachments

  %w[submitted scheduled published].each do |state|
    test "A #{state} publication is not valid without an attachment" do
      publication = build("#{state}_publication", attachments: [])
      assert_not publication.valid?
      assert_match %r{an attachment or HTML version before being #{state}}, publication.errors[:base].first
    end
  end

  test "is not valid for publishing without attachments" do
    publication = build(:published_publication, attachments: [])
    assert_not publication.valid?

    publication = build(:published_publication, attachments: [build(:external_attachment)])
    assert publication.valid?
  end

  test "should build a draft copy of the existing publication" do
    published = create(
      :published_publication,
      :with_file_attachment,
      first_published_at: Date.parse("2010-01-01"),
      publication_type_id: PublicationType::ResearchAndAnalysis.id,
    )

    draft = published.create_draft(create(:writer))

    assert_kind_of Attachment, published.attachments.first
    assert_not_equal published.attachments, draft.attachments
    assert_equal published.attachments.first.attachment_data,
                 draft.attachments.first.attachment_data
    assert_equal published.first_published_at, draft.first_published_at
    assert_equal published.publication_type, draft.publication_type
  end

  test "should allow setting of publication type" do
    publication = build(:publication, publication_type: PublicationType::PolicyPaper)
    assert publication.valid?
  end

  test "should be invalid without a publication type" do
    publication = build(:publication, publication_type: nil)
    assert_not publication.valid?
  end

  test 'superseded publications are valid with the "unknown" publication_type' do
    publication = build(:superseded_publication, publication_type: PublicationType::Unknown)
    assert publication.valid?
  end

  test ".in_chronological_order returns publications in ascending order of first_published_at" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    mar = create(:publication, first_published_at: Date.parse("2011-03-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan, feb, mar], Publication.in_chronological_order.to_a
  end

  test ".in_reverse_chronological_order returns publications in descending order of first_published_at" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    mar = create(:publication, first_published_at: Date.parse("2011-03-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [mar, feb, jan], Publication.in_reverse_chronological_order.to_a
  end

  test ".published_before returns editions whose first_published_at is before the given date" do
    jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    _feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [jan], Publication.published_before("2011-01-29").to_a
  end

  test ".published_after returns editions whose first_published_at is after the given date" do
    _jan = create(:publication, first_published_at: Date.parse("2011-01-01"))
    feb = create(:publication, first_published_at: Date.parse("2011-02-01"))
    assert_equal [feb], Publication.published_after("2011-01-29").to_a
  end

  test "new instances are access_limited based on their publication_type" do
    limit_by_default, dont_limit_by_default = PublicationType.all.partition(&:access_limited_by_default?).map(&:first)
    e = build(:draft_publication, publication_type: limit_by_default)
    assert e.access_limited?
    e = build(:draft_publication, publication_type: dont_limit_by_default)
    assert_not e.access_limited?
  end

  test "new instances respect local access_limited over their publication_type" do
    limit_by_default, dont_limit_by_default = PublicationType.all.partition(&:access_limited_by_default?).map(&:first)
    e = build(:draft_publication, publication_type: limit_by_default, access_limited: false)
    assert_not e.access_limited?
    e = build(:draft_publication, publication_type: dont_limit_by_default, access_limited: true)
    assert e.access_limited?
  end

  test "existing instances don't change access_limit when their publication_type does" do
    limit_by_default, dont_limit_by_default = PublicationType.all.partition(&:access_limited_by_default?).map(&:first)
    e = create(:draft_publication, access_limited: false)
    e.publication_type = limit_by_default
    assert_not e.access_limited?
    e = create(:draft_publication, access_limited: true)
    e.publication_type = dont_limit_by_default
    assert e.access_limited?
  end

  test "should be translatable" do
    publication = build(:draft_publication)
    assert publication.translatable?
  end

  test "is not translatable when non-English" do
    assert_not build(:publication, primary_locale: :es).translatable?
  end

  test "can associate publications with topical events" do
    publication = create(:publication)
    assert publication.can_be_associated_with_topical_events?
    assert topical_event = publication.topical_events.create!(name: "Test", description: "Test")
    assert_equal [publication], topical_event.publications
  end

  test "#search_index should include has_command_paper and has_act_paper" do
    pub = create(:publication)
    pub.stubs(:has_command_paper?).returns(true)
    pub.stubs(:has_act_paper?).returns(true)

    assert pub.search_index[:has_command_paper] == true
    assert pub.search_index[:has_act_paper] == true
  end

  test "#search_index detailed_format should be hard-coded for stats publication types" do
    # NationalStatistics and OfficialStatistics were renamed in Oct 2015 but
    # their detailed_format in Rummager needs to stay the same
    assert_equal "statistics-national-statistics", create(:published_national_statistics).search_index["detailed_format"]
    assert_equal "statistics", create(:published_statistics).search_index["detailed_format"]
  end

  test "#has_changed_publication_type? false if no previous edition" do
    publication = create(:publication)
    assert_not publication.has_changed_publication_type?
  end

  test "#has_changed_publication_type? false if previous edition has the same type" do
    published_publication = create(:published_policy_paper)
    publication = create(:draft_policy_paper, document: published_publication.document)
    assert_not publication.has_changed_publication_type?
  end

  test "#has_changed_publication_type? true if previous edition has a different type" do
    published_publication = create(:published_national_statistics)
    publication = create(:draft_policy_paper, document: published_publication.document)
    assert publication.has_changed_publication_type?
  end

  test "#path_name returns 'publication' by default" do
    publication = create(:publication)
    assert_equal publication.path_name, "publication"
  end

  test "#path_name returns 'statistic' for statistical types" do
    statistics = create(:published_national_statistics)
    assert_equal statistics.path_name, "statistic"
  end

  test "#all_nation_applicability_selected? false if first draft and unsaved" do
    unsaved_publication = build(:publication)
    assert_not unsaved_publication.all_nation_applicability_selected?
  end

  test "#all_nation_applicability_selected? responds to all_nation_applicability once created" do
    published_publication = create(:publication)
    assert published_publication.all_nation_applicability_selected?
    published_with_excluded = create(:published_publication_with_excluded_nations, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.scotland, alternative_url: "http://scotland.com")])
    assert_not published_with_excluded.all_nation_applicability_selected?
  end
end
