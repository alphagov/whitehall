# encoding: utf-8

require 'test_helper'

class DocumentHelperTest < ActionView::TestCase
  include PublicDocumentRoutesHelper

  test "#edition_organisation_class returns the slug of the first organisation of the edition" do
    organisations = [create(:organisation), create(:organisation)]
    edition = create(:edition, organisations: organisations)
    assert_equal organisations.first.slug, edition_organisation_class(edition)
  end

  test '#edition_organisation_class returns "no_organisation" if doc has no organisation' do
    edition = build(:edition)
    edition.organisations = []
    assert_equal 'unknown_organisation', edition_organisation_class(edition)
  end

  test "should generate a national statistics logo for a national statistic" do
    publication = create(:publication, publication_type_id: PublicationType::NationalStatistics.id)
    assert_match /National statistics/, national_statistics_logo(publication)
  end

  test "should generate no national statistics logo for an edition that is not a national statistic" do
    publication = create(:publication)
    refute_match /National statistics/, national_statistics_logo(publication)
  end

  test "should generate list of links to inapplicable nations with alternative URL" do
    publication = create(:publication, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.scotland, alternative_url: "http://scotland.com")])
    html = list_of_links_to_inapplicable_nations(publication.nation_inapplicabilities)
    assert_select_within_html html, "a[href='http://scotland.com']", text: "Scotland"
  end

  test "should generate list of inapplicable nations without alternative URL" do
    publication = create(:publication, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.wales, alternative_url: nil)])
    assert_equal "Wales", list_of_links_to_inapplicable_nations(publication.nation_inapplicabilities)
  end

  test "#see_alternative_urls_for_inapplicable_nations lists names and links if any alternative urls exist" do
    publication = create(:publication, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.scotland, alternative_url: "http://scotland.com")])
    html = see_alternative_urls_for_inapplicable_nations(publication)
    assert_select_within_html html, "a[href='http://scotland.com']", text: "Scotland"
    assert html.starts_with?(" (see publication for ")
  end

  test "#see_alternative_urls_for_inapplicable_nations skips nations without alternative urls" do
    publication = create(:publication, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.scotland, alternative_url: "http://scotland.com"), create(:nation_inapplicability, nation: Nation.wales, alternative_url: "")])
    html = see_alternative_urls_for_inapplicable_nations(publication)
    refute_match /Wales/, html
  end

  test "#see_alternative_urls_for_inapplicable_nations returns nothing if no alternative urls exist" do
    publication = create(:publication)
    html = see_alternative_urls_for_inapplicable_nations(publication)
    assert_nil html
  end

  test "should return nil for humanized content type when file extension is nil" do
    assert_nil humanized_content_type(nil)
  end

  test "should return DOC specific thumbnail for DOC files" do
    attachment = create(:file_attachment, file: fixture_file_upload('sample.docx', 'application/msword'))
    assert_match /pub-cover-doc\.png/, attachment_thumbnail(attachment)
  end

  test "should return spreadsheet specific thumbnail for spreadsheet files" do
    attachment = create(:file_attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))
    assert_match /pub-cover-spreadsheet\.png/, attachment_thumbnail(attachment)
  end

  test "should return HTML specific thumbnail for HTML attachments" do
    publication = create(:published_publication, :with_html_attachment)
    assert_match /pub-cover-html\.png/, attachment_thumbnail(publication.attachments.first)
  end

  test "should return PDF Document for humanized content type" do
    assert_equal '<abbr title="Portable Document Format">PDF</abbr>', humanized_content_type("pdf")
    assert_equal '<abbr title="Portable Document Format">PDF</abbr>', humanized_content_type("PDF")
  end

  test "should return CSV Document for humanized content type" do
    assert_equal '<abbr title="Comma-separated Values">CSV</abbr>', humanized_content_type("csv")
  end

  test "should return RTF Document for humanized content type" do
    assert_equal '<abbr title="Rich Text Format">RTF</abbr>', humanized_content_type("rtf")
  end

  test "should return PNG Image for humanized content type" do
    assert_equal '<abbr title="Portable Network Graphic">PNG</abbr>', humanized_content_type("png")
  end

  test "should return JPEG Document for humanized content type" do
    assert_equal "JPEG", humanized_content_type("jpg")
  end

  test "should return MS Word Document for humanized content type" do
    assert_equal "MS Word Document", humanized_content_type("doc")
    assert_equal "MS Word Document", humanized_content_type("docx")
  end

  test "should return MS Excel Spreadsheet for humanized content type" do
    assert_equal "MS Excel Spreadsheet", humanized_content_type("xls")
    assert_equal "MS Excel Spreadsheet", humanized_content_type("xlsx")
  end

  test "should return MS Powerpoint Presentation for humanized content type" do
    assert_equal "MS Powerpoint Presentation", humanized_content_type("ppt")
    assert_equal "MS Powerpoint Presentation", humanized_content_type("pptx")
  end

  test "should return Zip archive for humanized content type" do
    assert_equal '<abbr title="Zip archive">ZIP</abbr>', humanized_content_type("zip")
  end

  test "should return native language name for locale" do
    assert_equal "English", native_language_name_for(:en)
    assert_equal "Español", native_language_name_for(:es)
  end

  test '#link_to_translated_object links to an English edition' do
    edition = create(:publication)
    assert_dom_equal %Q(<a href="#{public_document_path(edition, locale: :en)}">English</a>),
      link_to_translated_object(edition, :en)
  end

  test "link_to_translated_object links to a translated edition" do
    edition = create(:publication)
    with_locale(:fr) { edition.update_attributes!(title: 'french-title', summary: 'french-summary', body: 'french-body') }

    assert_dom_equal %Q(<a href="#{public_document_path(edition, locale: :fr)}">Français</a>),
      link_to_translated_object(edition, :fr)
  end

  test "link_to_translated_object links to corporate information pages under their organisation" do
    info_page = create(:corporate_information_page)

    assert_dom_equal %Q(<a href="#{polymorphic_path([info_page.organisation, info_page], locale: :en)}">English</a>),
      link_to_translated_object(info_page, :en)
  end

  test "link_to_translated_object handles decorated editions" do
    edition = create(:publication)
    decorated_edition = PublicationesquePresenter.new(edition, 'context')
    assert_dom_equal %Q(<a href="#{public_document_path(edition, locale: :en)}">English</a>),
      link_to_translated_object(decorated_edition, :en)
  end

  test "link_to_translated_object handles linking to resource actions, i.e. organisation about pages" do
    organisation = create(:organisation)

    assert_dom_equal %Q(<a href="#{polymorphic_path([:about, organisation], locale: :cy)}">Cymraeg</a>),
      link_to_translated_object([:about, organisation], :cy)
  end

  test "document_metadata does not have any links for simple document" do
    edition = create(:publication)
    assert_equal [], document_metadata(edition)
  end

  test "document_metadata generates policy metadata" do
    policy = create(:published_policy)
    edition = create(:news_article, related_policy_ids: [policy])
    metadata = document_metadata(edition, [policy])[0]
    assert_equal metadata[:title], "Policy"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              public_document_path(policy),
                              text: policy.title
  end

  test "document_metadata generates topic metadata" do
    topic = create(:topic)
    edition = create(:news_article, topics: [topic])
    metadata = document_metadata(edition, [], [topic])[0]
    assert_equal metadata[:title], "Topic"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              topic_path(topic),
                              text: topic.name
  end

  test "document_metadata generates topical event metadata" do
    topical_event = create(:topical_event)
    edition = create(:news_article, topical_events: [topical_event])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Topical event"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              topical_event_path(topical_event),
                              text: topical_event.name
  end

  test "document_metadata generates ministerial role metadata" do
    role = create(:ministerial_role)
    edition = create(:policy, ministerial_roles: [role])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Minister"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              ministerial_role_path(role),
                              text: role.current_person_name(role.name)
  end

  test "document_metadata generates speech delivery metadata" do
    person = create(:person)
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:published_speech, role_appointment: role_appointment)
    metadata = document_metadata(speech)[0]
    assert_equal metadata[:title], "Minister"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              person_path(person),
                              text: person.name
  end

  test "document_metadata generates operational_field metadata" do
    operational_field = build(:operational_field)
    edition = create(:published_fatality_notice, operational_field: operational_field)
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Field of operation"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              operational_field_path(operational_field),
                              text: operational_field.name
  end

  test "document_metadata generates role_appointments metadata" do
    person = create(:person)
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    edition = create(:news_article, role_appointments: [role_appointment])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Minister"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              person_path(person),
                              text: person.name
  end

  test "document_metadata generates world_locations metadata" do
    world_location = create(:world_location)
    edition = create(:published_publication, world_locations: [world_location])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "World location"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              world_location_path(world_location),
                              text: world_location.name
  end

  test "document_metadata generates worldwide_organisations metadata" do
    organisation = create(:worldwide_organisation)
    edition = create(:draft_worldwide_priority, worldwide_organisations: [organisation])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Worldwide organisation"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              worldwide_organisation_path(organisation),
                              text: organisation.name
  end

  test "document_metadata generates inapplicable_nations metadata" do
    edition = create(:publication, nation_inapplicabilities: [create(:nation_inapplicability, nation: Nation.england, alternative_url: nil)])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Applies to"
    assert_match(/Wales/, metadata[:data][0])
  end

  test "document_metadata generates policy_team metadata" do
    policy_team = create(:policy_team)
    edition = create(:policy, policy_teams: [policy_team])
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Policy team"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              policy_team_path(policy_team),
                              text: policy_team.name
  end

  test "document_metadata generates policy_advisory_groups metadata" do
    policy_advisory_group = create(:policy_advisory_group)
    edition = create(:policy, policy_advisory_groups: [policy_advisory_group])
    metadata = document_metadata(edition)[0]
    assert_equal(metadata[:title], "Advisory groups")
    html = metadata[:data][0]
    assert_select_within_html html, "a[href=?]", policy_advisory_group_path(policy_advisory_group)
    assert_select_within_html html, 'a', policy_advisory_group.name
  end

  test "document_metadata generates part_of_series metadata" do
    organisation = create(:organisation)
    edition = create(:published_publication)
    series = create(:document_series, :with_group, organisation: organisation)
    series.groups.first.documents = [edition.document]
    metadata = document_metadata(edition)[0]
    assert_equal metadata[:title], "Series"
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              organisation_document_series_path(organisation, series),
                              text: series.name
  end

  test "document_metadata generates statistical_data_sets metadata" do
    statistical_data_set = create(:published_statistical_data_set)
    edition = create(:published_publication, statistical_data_sets: [statistical_data_set])
    metadata = document_metadata(edition)[0]
    assert_equal(metadata[:title], "Live data")
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              public_document_path(statistical_data_set),
                              text: statistical_data_set.title
  end

  test 'document_metadata includes worldwdide priorities in metadata' do
    priority = create(:published_worldwide_priority)
    edition = create(:published_consultation, worldwide_priorities: [priority])

    metadata = document_metadata(edition)[0]
    assert_equal 'Worldwide priorities', metadata[:title]
    assert_select_within_html metadata[:data][0],
                              "a[href=?]",
                              public_document_path(priority),
                              text: priority.title
  end
end
