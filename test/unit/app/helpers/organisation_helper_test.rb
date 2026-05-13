require "test_helper"

class OrganisationHelperTest < ActionView::TestCase
  include ApplicationHelper

  test "returns acronym in abbr tag if present" do
    organisation = build(:organisation, acronym: "BLAH", name: "Building Law and Hygiene")
    assert_equal %(<abbr title="Building Law and Hygiene">BLAH</abbr>), organisation_relationship_display_name(organisation)
  end

  test "returns name when acronym is nil" do
    organisation = build(:organisation, acronym: nil, name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_relationship_display_name(organisation)
  end

  test "returns name when acronym is empty" do
    organisation = build(:organisation, acronym: "", name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_relationship_display_name(organisation)
  end

  test "returns name formatted for logos" do
    organisation = build(:organisation, name: "Building Law and Hygiene", logo_formatted_name: "Building Law\nand Hygiene")
    assert_equal "Building Law<br/>and Hygiene", organisation_logo_name(organisation)
    assert_equal "Building Law and Hygiene", organisation_logo_name(organisation, stacked: false)
  end
end

class OrganisationHelperDisplayNameWithParentalRelationshipTest < ActionView::TestCase
  include OrganisationHelper

  def strip_html_tags(html)
    html.gsub(/<[^>]*?>/, "")
  end

  def assert_relationship_type_is_described_as(type_key, expected_description, org_name, parent_org_name)
    parent = create(:organisation, name: parent_org_name)
    child = create(:organisation, parent_organisations: [parent], organisation_type: OrganisationType.get(type_key), name: org_name)
    actual_html = organisation_display_name_and_parental_relationship(child)
    assert_equal expected_description, strip_html_tags(actual_html)
  end

  def assert_definite_article_skipped(parent_organisation_name)
    parent = create(:organisation, name: parent_organisation_name)
    child = create(:organisation, parent_organisations: [parent], organisation_type: OrganisationType.ministerial_department)
    actual_html = organisation_display_name_and_parental_relationship(child)
    assert_match %r{of #{parent.name}}, strip_html_tags(actual_html)
  end

  def assert_display_name_text(organisation, expected_text)
    actual_html = organisation_display_name_and_parental_relationship(organisation)
    assert_equal expected_text, strip_html_tags(actual_html)
  end

  test "basic sentence construction" do
    parent = create(:ministerial_department, acronym: "DBR", name: "Department of Building Regulation")
    child = create(
      :organisation,
      acronym: "BLAH",
      name: "Building Law and Hygiene",
      parent_organisations: [parent],
      organisation_type: OrganisationType.executive_agency,
    )
    expected = %(BLAH is an executive agency, sponsored by the Department of Building Regulation.)
    assert_display_name_text child, expected
  end

  test "string returned is html safe" do
    parent = create(:ministerial_department, name: "Department of Economy & Trade")
    child = create(
      :organisation,
      acronym: "B&B",
      name: "Banking & Business",
      parent_organisations: [parent],
      organisation_type: OrganisationType.executive_agency,
    )
    expected = %(B&amp;B is an executive agency, sponsored by the Department of Economy &amp; Trade.)
    assert_display_name_text child, expected
    assert organisation_display_name_and_parental_relationship(child).html_safe?
  end

  test "description of parent organisations" do
    parent = create(:ministerial_department, acronym: "DBR", name: "Department of Building Regulation")
    expected = %(DBR is a ministerial department.)
    assert_display_name_text parent, expected
  end

  test "links to parent organisation" do
    parent = create(:organisation, name: "Testing Agency")
    child = create(:organisation, name: "Department of Testing", parent_organisations: [parent])
    assert_match %r{the <a class="brand__color" href="/government/organisations/#{parent.to_param}">#{parent.name}</a>}, organisation_display_name_and_parental_relationship(child)
  end

  test "relationship types are described correctly and trailing spaces are removed" do
    assert_relationship_type_is_described_as(:ministerial_department, "The Department of Testing is a ministerial department of the Testing Agency.", "Department of Testing ", "Testing Agency ")
    assert_relationship_type_is_described_as(:non_ministerial_department, "The Department of Testing 2 is a non-ministerial department.", "Department of Testing 2", "doesn't matter ")
    assert_relationship_type_is_described_as(:executive_agency, "The Department of Testing 3 is an executive agency, sponsored by the Testing Agency 3.", "Department of Testing 3 ", "Testing Agency 3 ")
    assert_relationship_type_is_described_as(:executive_ndpb, "The Department of Testing 4 is an executive non-departmental public body, sponsored by the Testing Agency 4.", "Department of Testing 4", "Testing Agency 4 ")
    assert_relationship_type_is_described_as(:advisory_ndpb, "The Department of Testing 5 is an advisory non-departmental public body, sponsored by the Testing Agency 5.", "Department of Testing 5", "Testing Agency 5 ")
    assert_relationship_type_is_described_as(:special_health_authority, "The Department of Testing 6 is a special health authority, sponsored by the Testing Agency 6.", "Department of Testing 6 ", "Testing Agency 6 ")
    assert_relationship_type_is_described_as(:tribunal, "The Department of Testing 7 is a tribunal of the Testing Agency 7.", "Department of Testing 7 ", "Testing Agency 7 ")
    assert_relationship_type_is_described_as(:public_corporation, "The Department of Testing 8 is a public corporation of the Testing Agency 8.", "Department of Testing 8", "Testing Agency 8 ")
    assert_relationship_type_is_described_as(:independent_monitoring_body, "The Department of Testing 9 is an independent monitoring body of the Testing Agency 9.", "Department of Testing 9 ", "Testing Agency 9 ")
    assert_relationship_type_is_described_as(:other, "The Department of Testing 10 works with the Testing Agency 10.", "Department of Testing 10 ", "Testing Agency 10  ")
  end

  test "definite article skipped for certain parent organisations" do
    assert_definite_article_skipped "Civil Service Resourcing"
    assert_definite_article_skipped "HM Treasury"
    assert_definite_article_skipped "Ordnance Survey"
    assert_definite_article_skipped "Homes England"
  end

  test "definite article added for certain organisations" do
    assert needs_definite_article?("Environment Agency")
  end

  test 'definite article skipped if name starts with "The"' do
    assert_definite_article_skipped "The National Archives"
  end

  test "multiple parent organisations reflected as in copy" do
    parent1 = create(:organisation)
    parent2 = create(:organisation)
    child = create(:organisation, parent_organisations: [parent1, parent2])
    result = organisation_display_name_and_parental_relationship(child)

    assert_match parent1.name, result
    assert_match parent2.name, result
  end

  test "single child organisation reflected as in copy" do
    child = create(:organisation)
    parent = create(:ministerial_department, acronym: "PAN", name: "Parent Organisation Name", child_organisations: [child])
    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert description.include? "1 public body"
  end

  test "multiple child organisations reflected as in copy" do
    child1 = create(:organisation)
    child2 = create(:organisation)
    parent = create(:ministerial_department, acronym: "PAN", name: "Parent Organisation Name", child_organisations: [child1, child2])
    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert description.include? "2 agencies and public bodies"
  end

  test "organisations with children are described correctly" do
    child = create(:organisation, acronym: "COO", name: "Child Organisation One")
    parent = create(:ministerial_department, acronym: "PAN", name: "Parent Organisation Name", child_organisations: [child])

    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert_equal "PAN is a ministerial department, supported by 1 public body.", strip_html_tags(description)
  end

  test "organisations of type other with children are described correctly" do
    child = create(:organisation, acronym: "CO", name: "Child Organisation")
    parent = create(:organisation, organisation_type_key: "other", acronym: "OON", name: "Other Organisation Name", child_organisations: [child])

    description = organisation_display_name_including_parental_and_child_relationships(parent)
    assert_equal "OON is supported by 1 public body.", strip_html_tags(description)
  end

  test "organisations of type other with no relationships are described correctly" do
    organisation = create(:organisation, organisation_type_key: "other", acronym: "OON", name: "Other Organisation Name")
    organisation.stubs(:supporting_bodies).returns([])

    description = organisation_display_name_including_parental_and_child_relationships(organisation)
    assert description.include? "Other Organisation Name"
    assert_equal "OON", strip_html_tags(description)
  end

  test "organisations of type other with parent and multiple children are described correctly" do
    child1 = create(:organisation, acronym: "CO", name: "Child Organisation 1")
    child2 = create(:organisation, acronym: "CO", name: "Child Organisation 2")
    parent = create(:organisation, acronym: "PO", name: "Department of Testing")
    org = create(:organisation, organisation_type_key: "other", acronym: "TO", name: "This Organisation", child_organisations: [child1, child2], parent_organisations: [parent])

    description = organisation_display_name_including_parental_and_child_relationships(org)
    assert_equal "TO works with the Department of Testing and is supported by 2 agencies and public bodies.", strip_html_tags(description)
  end
end
