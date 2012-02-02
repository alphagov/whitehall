require "test_helper"

class OrganisationHelperTest < ActionView::TestCase
  test "returns acroynm in abbr tag if present" do
    organisation = build(:organisation, acronym: "BLAH", name: "Building Law and Hygiene")
    assert_equal %{<abbr title="Building Law and Hygiene">BLAH</abbr>}, organisation_display_name(organisation)
  end

  test "returns name when acroynm is nil" do
    organisation = build(:organisation, acronym: nil, name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_display_name(organisation)
  end

  test "returns name when acroynm is empty" do
    organisation = build(:organisation, acronym: "", name: "Building Law and Hygiene")
    assert_equal "Building Law and Hygiene", organisation_display_name(organisation)
  end

  test 'organisation home page should be related to home page in organisation navigation' do
    organisation = create(:organisation, name: 'Cabinet Office')
    assert_equal organisation_path(organisation), current_organisation_navigation_path(controller: 'organisations', action: 'show', id: organisation.slug)
  end

  test 'organisation about page should be related to about page in organisation navigation' do
    organisation = create(:organisation, name: 'Cabinet Office')
    assert_equal about_organisation_path(organisation), current_organisation_navigation_path(controller: 'organisations', action: 'about', id: organisation.slug)
  end

  test 'organisation announcements page should be related to announcements page in organisation navigation' do
    organisation = create(:organisation, name: 'Cabinet Office')
    assert_equal announcements_organisation_path(organisation), current_organisation_navigation_path(controller: 'organisations', action: 'announcements', id: organisation.slug)
  end

  test 'should add current class to link if current page is related to link' do
    stubs(:current_organisation_navigation_path).returns('/some/path')
    html = organisation_navigation_link_to('Link body', '/some/path')
    anchor = Nokogiri::HTML.fragment(html)/'a'
    assert_equal 'Link body', anchor.inner_text
    assert_equal '/some/path', anchor.attr('href').value
    classes = (anchor.attr('class').try(:value) || '').split
    assert classes.include?('current')
  end

  test 'should not add current class to link if current page is not related to link' do
    stubs(:current_organisation_navigation_path).returns('/some/other/path')
    html = organisation_navigation_link_to('Link body', '/some/path')
    anchor = Nokogiri::HTML.fragment(html)/'a'
    assert_equal 'Link body', anchor.inner_text
    assert_equal '/some/path', anchor.attr('href').value
    classes = (anchor.attr('class').try(:value) || '').split
    refute classes.include?('current')
  end
end
