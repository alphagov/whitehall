require "test_helper"

class OrganisationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "returns acronym in abbr tag if present" do
    organisation = build(:organisation, acronym: "BLAH", name: "Building Law and Hygiene")
    assert_equal %{<abbr title="Building Law and Hygiene">BLAH</abbr>}, organisation_display_name(organisation)
  end

  test "returns name when acronym is nil" do
    organisation = build(:organisation, acronym: nil, name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_display_name(organisation)
  end

  test "returns name when acronym is empty" do
    organisation = build(:organisation, acronym: "", name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_display_name(organisation)
  end

  test "returns the name of a worldwide organisation" do
    organisation = build(:worldwide_organisation, name: "British Embassy, Atlantis")
    assert_equal "British Embassy, Atlantis", organisation_display_name(organisation)
  end

  test "returns name formatted for logos" do
    organisation = build(:organisation, name: "Building Law and Hygiene", logo_formatted_name: "Building Law\nand Hygiene")
    assert_equal "Building Law<br/>and Hygiene", organisation_logo_name(organisation)
    assert_equal "Building Law and Hygiene", organisation_logo_name(organisation, false)
  end

  test 'organisation_wrapper should place org specific class onto the div' do
    organisation = build(:organisation, slug: "organisation-slug-yeah", name: "Building Law and Hygiene")
    html = organisation_wrapper(organisation) {}
    div = Nokogiri::HTML.fragment(html) / 'div'
    assert_match %r[organisation-slug-yeah], div.attr('class').value
  end

  test 'organisation_wrapper should place brand colour class onto the div' do
    organisation = build(:organisation, organisation_brand_colour_id: OrganisationBrandColour::HMGovernment.id)
    html = organisation_wrapper(organisation) {}
    div = Nokogiri::HTML.fragment(html) / 'div'
    assert_match %r[hm-government-brand-colour], div.attr('class').value
  end

  test 'organisation_brand_colour_class generates blank class when org has no brand colour' do
    org = build(:organisation)
    assert_equal organisation_brand_colour_class(org), ""
  end

  test 'organisation_brand_colour_class generates correct class for brand colour' do
    org = build(:organisation, organisation_brand_colour_id: 2)
    assert_equal organisation_brand_colour_class(org), "cabinet-office-brand-colour"
  end

  test 'extra_board_member_class returns clear_person at correct interval when many important board members' do
    organisation = stub('organistion', important_board_members: 2)
    assert_equal 'clear-person', extra_board_member_class(organisation, 0)
    assert_equal '', extra_board_member_class(organisation, 1)
    assert_equal '', extra_board_member_class(organisation, 2)
    assert_equal '', extra_board_member_class(organisation, 3)
    assert_equal 'clear-person', extra_board_member_class(organisation, 4)
  end

  test 'extra_board_member_class returns clear_person at correct interval when one important board member' do
    organisation = stub('organistion', important_board_members: 1)
    assert_equal 'clear-person', extra_board_member_class(organisation, 0)
    assert_equal '', extra_board_member_class(organisation, 1)
    assert_equal '', extra_board_member_class(organisation, 2)
    assert_equal 'clear-person', extra_board_member_class(organisation, 3)
  end

  test 'organisation_count_paragraph includes the number of orgs in a filterable container' do
    orgs = [build(:organisation), build(:organisation)]
    render plain: organisation_count_paragraph(orgs)
    assert_select '.js-filter-count', text: '2'
  end

  test '#organisation_govuk_status_description describes an organisation that no longer exists' do
    organisation = build(:closed_organisation, name: 'Beard Ministry')

    assert_equal "Beard Ministry has closed", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description for an organisation that no longer exists includes the closed date if available' do
    closed_time = 1.day.ago
    organisation = build(:closed_organisation, name: 'Beard Ministry', closed_at: closed_time)

    assert_equal "Beard Ministry closed in November 2011", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation that has been replaced' do
    superseding_organisation = create(:organisation, name: 'Superseding organisation')
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', govuk_closed_status: 'replaced', superseding_organisations: [superseding_organisation])

    assert_equal "Beard Ministry was replaced by <a href=\"/government/organisations/superseding-organisation\">Superseding organisation</a>", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description for a replaced organisation includes the closed date if available' do
    closed_time = 1.day.ago
    superseding_organisation = create(:organisation, name: 'Superseding organisation')
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', closed_at: closed_time, govuk_closed_status: 'replaced', superseding_organisations: [superseding_organisation])

    assert_equal "Beard Ministry was replaced by <a href=\"/government/organisations/superseding-organisation\">Superseding organisation</a> in November 2011",
    organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation that has been split' do
    superseding_organisation_1 = create(:organisation, name: 'Superseding organisation 1')
    superseding_organisation_2 = create(:organisation, name: 'Superseding organisation 2')
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', govuk_closed_status: 'split', superseding_organisations: [superseding_organisation_1, superseding_organisation_2])

    assert_equal "Beard Ministry was replaced by <a href=\"/government/organisations/superseding-organisation-1\">Superseding organisation 1</a> and <a href=\"/government/organisations/superseding-organisation-2\">Superseding organisation 2</a>", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description for an organisation that has been split includes the closed date if available' do
    superseding_organisation_1 = create(:organisation, name: 'Superseding organisation 1')
    superseding_organisation_2 = create(:organisation, name: 'Superseding organisation 2')
    closed_time = 1.day.ago
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', closed_at: closed_time, govuk_closed_status: 'split', superseding_organisations: [superseding_organisation_1, superseding_organisation_2])

    assert_equal "Beard Ministry was replaced by <a href=\"/government/organisations/superseding-organisation-1\">Superseding organisation 1</a> and <a href=\"/government/organisations/superseding-organisation-2\">Superseding organisation 2</a> in November 2011",
    organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation that has merged' do
    superseding_organisation = create(:organisation, name: 'Superseding organisation')
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', govuk_closed_status: 'merged', superseding_organisations: [superseding_organisation])

    assert_equal "Beard Ministry is now part of <a href=\"/government/organisations/superseding-organisation\">Superseding organisation</a>", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation that changed its name' do
    superseding_organisation = create(:organisation, name: 'Superseding organisation')
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', govuk_closed_status: 'changed_name', superseding_organisations: [superseding_organisation])

    assert_equal "Beard Ministry is now called <a href=\"/government/organisations/superseding-organisation\">Superseding organisation</a>", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation that has left government' do
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', govuk_closed_status: 'left_gov')

    assert_equal "Beard Ministry is now independent of the UK government", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation that is devolved' do
    superseding_organisation = create(:organisation, name: 'Superseding organisation')
    organisation = build(:organisation, name: 'Beard Ministry', govuk_status: 'closed', govuk_closed_status: 'devolved', superseding_organisations: [superseding_organisation])

    assert_equal "Beard Ministry is now run by the <a href=\"/government/organisations/superseding-organisation\">Superseding organisation</a>", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes an organisation which is closed and devolved to regional government, and superseeded by a devolved administration' do
    superseeding_administration = create(:devolved_administration, name: 'Scottish Government')
    organisation = create(:organisation, name: 'Creative Scotland', govuk_status: 'closed', govuk_closed_status: 'devolved', superseding_organisations: [superseeding_administration])

    assert_equal "Creative Scotland is a body of the <a href=\"/government/organisations/scottish-government\">Scottish Government</a>", organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description links to transitioning organisations' do
    organisation = build(:organisation, name: 'Taxidermy Commission', govuk_status: 'transitioning', url: 'http://taxidermy.uk')

    assert_equal 'Taxidermy Commission is in the process of joining GOV.UK. In the meantime, <a href="http://taxidermy.uk">http://taxidermy.uk</a> remains the official source.',
      organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description links to joining organisations when a url is available' do
    organisation = build(:organisation, name: 'Parrot Office', govuk_status: 'joining', url: 'http://parrot.org')

    assert_equal 'Parrot Office currently has a <a href="http://parrot.org">separate website</a> but will soon be incorporated into GOV.UK',
      organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes a joining organisation without a website' do
    organisation = build(:organisation, name: 'Parrot Office', govuk_status: 'joining')

    assert_equal 'Parrot Office will soon be incorporated into GOV.UK', organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description describes exempt organisations without a website' do
    organisation = build(:organisation, name: 'Potato Jazz Association', govuk_status: 'exempt')

    assert_equal 'Potato Jazz Association has no website', organisation_govuk_status_description(organisation)
  end

  test '#organisation_govuk_status_description links to exempt organisations when a url is available' do
    organisation = build(:organisation, name: 'Potato Jazz Association', govuk_status: 'exempt', url: 'http://pots-jazz.fm')

    assert_equal 'Potato Jazz Association has a <a href="http://pots-jazz.fm">separate website</a>', organisation_govuk_status_description(organisation)
  end

  test '#superseding_organisations_text should return a paragraph listing superseding organisations with the appropriate links' do
    organisation = build(:organisation, superseding_organisations: [
      build(:organisation, name: "Ministry of Makeup", slug: "ministry-of-makeup"),
      build(:organisation, name: "Bureaucracy of Beards", slug: "bureaucracy-of-beards"),
      build(:organisation, name: "Department of Dandruff", slug: "department-of-dandruff")
    ])
    text = superseding_organisations_text(organisation)
    assert_equal "<a href=\"/government/organisations/ministry-of-makeup\">Ministry of Makeup</a>, <a href=\"/government/organisations/bureaucracy-of-beards\">Bureaucracy of Beards</a> and <a href=\"/government/organisations/department-of-dandruff\">Department of Dandruff</a>", text
  end

  test '#govuk_status_meta_data_for joining and transitioning orgs should return "moving to GOV.UK"' do
    rendered = Nokogiri::HTML::DocumentFragment.parse(govuk_status_meta_data_for(build(:organisation, govuk_status: 'joining')))
    assert_equal "moving to GOV.UK", rendered.at_css('.metadata').text
    rendered = Nokogiri::HTML::DocumentFragment.parse(govuk_status_meta_data_for(build(:organisation, govuk_status: 'transitioning')))
    assert_equal "moving to GOV.UK", rendered.at_css('.metadata').text
  end

  test '#govuk_status_meta_data_for exempt orgs should return "separate website"' do
    rendered = Nokogiri::HTML::DocumentFragment.parse(govuk_status_meta_data_for(build(:organisation, govuk_status: 'exempt')))
    assert_equal "separate website", rendered.at_css('.metadata').text
  end

  test '#govuk_status_meta_data_for live and closed orgs should return nothing' do
    assert_nil govuk_status_meta_data_for(build(:organisation, govuk_status: 'live'))
    assert_nil govuk_status_meta_data_for(build(:organisation, govuk_status: 'closed'))
  end

  test "#show_corporate_information_pages? for organisations that are not live should be false" do
    organisation = create(:organisation, :closed)

    refute show_corporate_information_pages?(organisation)
  end

  test "#show_corporate_information_pages? for live organisations should be true" do
    organisation = create(:organisation)

    assert show_corporate_information_pages?(organisation)
  end

  test "#show_corporate_information_pages? for live courts with published corporate information pages should be true" do
    organisation = create(:court)
    create(:published_corporate_information_page, organisation: organisation)

    assert show_corporate_information_pages?(organisation)
  end

  test "#show_corporate_information_pages? for live courts with only a published about_us page should be false" do
    organisation = create(:court)
    create(:about_corporate_information_page, organisation: organisation)

    refute show_corporate_information_pages?(organisation)
  end

  test "#show_corporate_information_pages? for live courts with published about_us and other corporate information pages should be true" do
    organisation = create(:court)
    create(:published_corporate_information_page, organisation: organisation)
    create(:about_corporate_information_page, organisation: organisation)

    assert show_corporate_information_pages?(organisation)
  end
end

class OrganisationHelperDisplayNameWithParentalRelationshipTest < ActionView::TestCase
  include OrganisationHelper

  def strip_html_tags(html)
    html.gsub(/<[^>]*?>/, '')
  end

  def assert_relationship_type_is_described_as(type_key, expected_description)
    parent = create(:organisation)
    child = create(:organisation, parent_organisations: [parent], organisation_type: OrganisationType.get(type_key))
    expected_text = expected_description.sub('{this_org_name}', child.name).sub('{parent_org_name}', parent.name)
    actual_html = organisation_display_name_and_parental_relationship(child)
    assert_equal expected_text, strip_html_tags(actual_html)
  end

  def assert_definite_article_skipped(parent_organisation_name)
    parent = create(:organisation, name: parent_organisation_name)
    child = create(:organisation, parent_organisations: [parent], organisation_type: OrganisationType.ministerial_department)
    actual_html = organisation_display_name_and_parental_relationship(child)
    assert_match %r[of #{parent.name}], strip_html_tags(actual_html)
  end

  def assert_display_name_text(organisation, expected_text)
    actual_html = organisation_display_name_and_parental_relationship(organisation)
    assert_equal expected_text, strip_html_tags(actual_html)
  end

  test 'basic sentence construction' do
    parent = create(:ministerial_department, acronym: "DBR", name: "Department of Building Regulation")
    child = create(:organisation, acronym: "BLAH",
      name: "Building Law and Hygiene", parent_organisations: [parent],
      organisation_type: OrganisationType.executive_agency)
    expected = %{BLAH is an executive agency, sponsored by the Department of Building Regulation.}
    assert_display_name_text child, expected
  end

  test 'string returned is html safe' do
    parent = create(:ministerial_department, name: "Department of Economy & Trade")
    child = create(:organisation, acronym: "B&B",
      name: "Banking & Business", parent_organisations: [parent],
      organisation_type: OrganisationType.executive_agency)
    expected = %{B&amp;B is an executive agency, sponsored by the Department of Economy &amp; Trade.}
    assert_display_name_text child, expected
    assert organisation_display_name_and_parental_relationship(child).html_safe?
  end

  test 'description of parent organisations' do
    parent = create(:ministerial_department, acronym: "DBR", name: "Department of Building Regulation")
    expected = %{DBR is a ministerial department.}
    assert_display_name_text parent, expected
  end

  test 'links to parent organisation' do
    parent = create(:organisation)
    child = create(:organisation, parent_organisations: [parent])
    assert_match %r{the <a href="/government/organisations/#{parent.to_param}">#{parent.name}</a>}, organisation_display_name_and_parental_relationship(child)
  end

  test 'relationship types are described correctly' do
    assert_relationship_type_is_described_as(:ministerial_department, '{this_org_name} is a ministerial department of the {parent_org_name}.')
    assert_relationship_type_is_described_as(:non_ministerial_department, '{this_org_name} is a non-ministerial department.')
    assert_relationship_type_is_described_as(:executive_agency, '{this_org_name} is an executive agency, sponsored by the {parent_org_name}.')
    assert_relationship_type_is_described_as(:executive_ndpb, '{this_org_name} is an executive non-departmental public body, sponsored by the {parent_org_name}.')
    assert_relationship_type_is_described_as(:advisory_ndpb, '{this_org_name} is an advisory non-departmental public body, sponsored by the {parent_org_name}.')
    assert_relationship_type_is_described_as(:tribunal_ndpb, '{this_org_name} is a tribunal non-departmental public body, sponsored by the {parent_org_name}.')
    assert_relationship_type_is_described_as(:public_corporation, '{this_org_name} is a public corporation of the {parent_org_name}.')
    assert_relationship_type_is_described_as(:independent_monitoring_body, '{this_org_name} is an independent monitoring body of the {parent_org_name}.')
    assert_relationship_type_is_described_as(:other, '{this_org_name} works with the {parent_org_name}.')
  end

  test 'definite article skipped for certain parent organisations' do
    assert_definite_article_skipped 'Civil Service Resourcing'
    assert_definite_article_skipped 'HM Treasury'
    assert_definite_article_skipped 'Ordnance Survey'
  end

  test 'definite article skipped if name starts with "The"' do
    assert_definite_article_skipped 'The National Archives'
  end

  test 'multiple parent organisations reflected as in copy' do
    parent_1 = create(:organisation)
    parent_2 = create(:organisation)
    child = create(:organisation, parent_organisations: [parent_1, parent_2])
    result = organisation_display_name_and_parental_relationship(child)
    assert_match parent_1.name, result
    assert_match parent_2.name, result
  end

  test 'single child organisation reflected as in copy' do
    child = create(:organisation)
    parent = create(:ministerial_department, acronym: "PAN", name: "Parent Organisation Name", child_organisations: [child])
    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert description.include? '1 public body'
  end

  test 'multiple child organisations reflected as in copy' do
    child_1 = create(:organisation)
    child_2 = create(:organisation)
    parent = create(:ministerial_department, acronym: "PAN", name: "Parent Organisation Name", child_organisations: [child_1, child_2])
    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert description.include? '2 agencies and public bodies'
  end

  test 'organisations with children are described correctly' do
    child = create(:organisation, acronym: "COO", name: "Child Organisation One")
    parent = create(:ministerial_department, acronym: "PAN", name: "Parent Organisation Name", child_organisations: [child])

    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert description.include? ', supported by'
  end

  test 'organisations of type other with children are described correctly' do
    child = create(:organisation, acronym: "CO", name: "Child Organisation")
    parent = create(:organisation, organisation_type_key: "other", acronym: "OON", name: "Other Organisation Name", child_organisations: [child])

    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert description.include? 'is supported by'
    refute description.include? 'is an other'
  end

  test 'organisations of type other with no relationships are described correctly' do
    organisation = create(:organisation, organisation_type_key: "other", acronym: "OON", name: "Other Organisation Name")
    organisation.stubs(:supporting_bodies).returns([])

    description = organisation_display_name_including_parental_and_child_relationships(organisation)
    assert description.include? 'Other Organisation Name'
    refute description.include? 'is an other'
  end
end
