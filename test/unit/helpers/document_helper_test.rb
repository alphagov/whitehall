# encoding: utf-8

require 'test_helper'

class DocumentHelperTest < ActionView::TestCase
  include PublicDocumentRoutesHelper
  include OrganisationHelper

  test "#edition_organisation_class returns the slug of the first organisation of the edition" do
    organisations = [create(:organisation, name: "An Organisation"),
                     create(:organisation, name: "Better Organisation")]
    edition = create(:publication, organisations: organisations)
    assert_equal organisations.first.slug, edition_organisation_class(edition)
  end

  test '#edition_organisation_class returns "no_organisation" if doc has no organisation' do
    edition = build(:publication)
    edition.organisations = []
    assert_equal 'unknown_organisation', edition_organisation_class(edition)
  end

  test "should generate a National Statistics logo for a national statistic" do
    publication = create(:publication, publication_type_id: PublicationType::NationalStatistics.id)
    assert_match %r[National Statistics], national_statistics_logo(publication)
  end

  test "should generate no National Statistics logo for an edition that is not a national statistic" do
    publication = create(:publication)
    refute_match %r[National Statistics], national_statistics_logo(publication)
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
    refute_match %r[Wales], html
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
    assert_match %r[pub-cover-doc\.png], attachment_thumbnail(attachment)
  end

  test "should return spreadsheet specific thumbnail for spreadsheet files" do
    attachment = create(:file_attachment, file: fixture_file_upload('sample-from-excel.csv', 'text/csv'))
    assert_match %r[pub-cover-spreadsheet\.png], attachment_thumbnail(attachment)
  end

  test "should return spreadsheet specific thumbnail for spreadsheet files with any case file extension" do
    attachment = create(:file_attachment, file: fixture_file_upload('sample_case.CSV', 'text/csv'))
    assert_match(/pub-cover-spreadsheet\.png/, attachment_thumbnail(attachment))
  end

  test "should return HTML specific thumbnail for HTML attachments" do
    publication = create(:published_publication, :with_html_attachment)
    assert_match %r[pub-cover-html\.png], attachment_thumbnail(publication.attachments.first)
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

  test "#link_to_translation should generate a link based on the current controller action with the given locale" do
    controller.stubs(:url_options).returns(
      action: "show",
      controller: "world_locations",
      locale: "it",
      id: "a-world-location"
    )
    assert_dom_equal %(<a lang="de" href="/world/a-world-location.de">Deutsch</a>),
      link_to_translation(:de)
  end

  test "#link_to_translation should not suffix URLs with 'en'" do
    controller.stubs(:url_options).returns(
      action: "show",
      controller: "world_locations",
      locale: "it",
      id: "a-world-location"
    )
    assert_dom_equal %(<a lang="en" href="/world/a-world-location">English</a>),
      link_to_translation(:en)
  end

  test "part_of_metadata does not have any links for a simple document" do
    edition = create(:publication)
    assert_equal [], part_of_metadata(edition)
  end

  test "part_of_metadata generates collection metadata" do
    organisation = create(:organisation)
    edition = create(:published_publication)
    collection = create(:published_document_collection, :with_group)
    collection.groups.first.documents = [edition.document]

    metadata_links = part_of_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              public_document_path(collection),
                              text: collection.title
  end

  test "part_of_metadata generates statistical data sets metadata" do
    statistical_data_set = create(:published_statistical_data_set)
    edition = create(:published_publication, statistical_data_sets: [statistical_data_set])

    metadata_links = part_of_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              public_document_path(statistical_data_set),
                              text: statistical_data_set.title
  end

  test "part_of_metadata generates topical events metadata" do
    topical_event = create(:topical_event)
    edition = create(:news_article, topical_events: [topical_event])

    metadata_links = part_of_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              topical_event_path(topical_event),
                              text: topical_event.name
  end

  test "part_of_metadata generates world_locations metadata" do
    world_location = create(:world_location)
    edition = create(:published_publication, world_locations: [world_location])

    metadata_links = part_of_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              world_location_path(world_location),
                              text: world_location.name
  end

  test "from_metadata generates lead_organisations metadata" do
    org = create(:organisation)
    edition = create(:speech, lead_organisations: [org])

    metadata_links = from_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              organisation_path(org),
                              text: org.name
  end

  test "from_metadata generates speech delivered by minister metadata" do
    person = create(:person)
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    speech = create(:published_speech, role_appointment: role_appointment)

    metadata_links = from_metadata(speech).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              person_path(person),
                              text: person.name
  end

  test "from_metadata generates role_appointments metadata" do
    person = create(:person)
    ministerial_role = create(:ministerial_role)
    role_appointment = create(:role_appointment, role: ministerial_role, person: person)
    edition = create(:news_article, role_appointments: [role_appointment])

    metadata_links = from_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              person_path(person),
                              text: person.name
  end

  test "from_metadata generates worldwide_organisations metadata" do
    organisation = create(:worldwide_organisation)
    edition = create(:draft_case_study, worldwide_organisations: [organisation])

    metadata_links = from_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              worldwide_organisation_path(organisation),
                              text: organisation.name
  end

  test "from_metadata generates supporting_organisations metadata" do
    org = create(:organisation)
    edition = create(:speech, supporting_organisations: [org])

    metadata_links = from_metadata(edition).join(' ')
    assert_select_within_html metadata_links,
                              "a[href=?]",
                              organisation_path(org),
                              text: org.name
  end
end
