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

  test "(on create) is not valid if the publication type does not match the announcement type" do
    accredited_official_announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id)
    non_accredited_publication = build(:draft_statistics)

    non_accredited_publication.statistics_announcement_id = accredited_official_announcement.id

    assert_not non_accredited_publication.valid?
    assert_equal non_accredited_publication.errors[:publication_type_id], ["does not match announcement type: must be '#{accredited_official_announcement.publication_type.singular_name}'"]
  end

  test "(on edit) is not valid if the publication type does not match the announcement type" do
    # statistics_announcement_id not available, statistics_announcement already set
    accredited_official_announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id)
    accredited_official_publication = create(:draft_national_statistics, statistics_announcement_id: accredited_official_announcement.id)

    accredited_official_publication.publication_type_id = PublicationType::OfficialStatistics.id

    assert_not accredited_official_publication.valid?
    assert_equal accredited_official_publication.errors[:publication_type_id], ["does not match announcement type: must be '#{accredited_official_announcement.publication_type.singular_name}'"]
  end

  test "it saves the announcement association" do
    accredited_official_announcement = create(:statistics_announcement, publication_type_id: PublicationType::NationalStatistics.id)
    accredited_official_publication = create(:draft_national_statistics, statistics_announcement_id: accredited_official_announcement.id)

    assert_equal accredited_official_announcement.reload.publication.id, accredited_official_publication.id
    assert_equal accredited_official_publication.statistics_announcement.id, accredited_official_announcement.id
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
    assert topical_event = publication.topical_events.create!(name: "Test", description: "Test", summary: "Test")
    assert_equal [publication], topical_event.publications
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
    unsaved_publication_with_document = build(:publication, document: build(:document))
    assert_not unsaved_publication.all_nation_applicability_selected?
    assert_not unsaved_publication_with_document.all_nation_applicability_selected?
  end

  test "#all_nation_applicability_selected? responds to all_nation_applicability once created" do
    published_publication = create(:publication)
    assert published_publication.all_nation_applicability_selected?
    published_with_excluded = create(:published_publication_with_excluded_nations, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.scotland, alternative_url: "http://scotland.com")])
    assert_not published_with_excluded.all_nation_applicability_selected?
  end
end
