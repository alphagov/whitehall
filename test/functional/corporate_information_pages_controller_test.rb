require "test_helper"

class CorporateInformationPagesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  view_test "show renders the summary as plain text" do
    @corporate_information_page = create(:corporate_information_page, :published, summary: "Just plain text")
    get :show, params: { organisation_id: @corporate_information_page.organisation, id: @corporate_information_page.slug }

    assert_select ".description", text: "Just plain text"
  end

  view_test "show renders the body as govspeak" do
    @corporate_information_page = create(:corporate_information_page, :published, body: "## Title\n\npara1\n\n")
    get :show, params: { organisation_id: @corporate_information_page.organisation, id: @corporate_information_page.slug }

    assert_select ".body" do
      assert_select "h2", "Title"
      assert_select "p", "para1"
    end
  end

  view_test "should link to world location organisation belongs to" do
    world_location = create(:world_location)
    worldwide_organisation = create(:worldwide_organisation, world_locations: [world_location])
    corporate_information_page = create(:corporate_information_page, :published, worldwide_organisation: worldwide_organisation, organisation: nil)

    get :show, params: { organisation: nil, worldwide_organisation_id: worldwide_organisation, id: corporate_information_page.slug }

    assert_select "a[href=?]", worldwide_organisation_path(worldwide_organisation)
    assert_select "a[href=?]", world_location_path(world_location)
  end

  view_test "should show description on organisation about subpage" do
    organisation = create(:organisation)
    create(:about_corporate_information_page, organisation: organisation, summary: "organisation-description")
    get :index, params: { organisation_id: organisation }
    assert_select ".description", text: "organisation-description"
  end

  view_test "should show links to the alternate languages for a translated organisation" do
    organisation = create(:organisation, translated_into: [:fr])
    create(:about_corporate_information_page, organisation: organisation, summary: "organisation-description")
    get :index, params: { organisation_id: organisation }
    expected_url = organisation_corporate_information_pages_path(organisation, locale: :fr)
    assert_select ".available-languages a[href='#{expected_url}']", text: Locale.new(:fr).native_language_name
  end

  view_test "should display published corporate publications on about-us page" do
    published_corporate_publication = create(:published_corporate_publication)
    draft_corporate_publication = create(:draft_corporate_publication)

    organisation = create(:organisation, editions: [
      published_corporate_publication,
      draft_corporate_publication
    ])

    get :index, params: { organisation_id: organisation }

    assert_select_object(published_corporate_publication)
    refute_select_object(draft_corporate_publication)
  end

  test "should display published corporate publications on about-us page in order published" do
    old_published_corporate_publication = create(:published_corporate_publication, first_published_at: Date.parse('2012-01-01'))
    new_published_corporate_publication = create(:published_corporate_publication, first_published_at: Date.parse('2012-01-03'))
    middle_published_corporate_publication = create(:published_corporate_publication, first_published_at: Date.parse('2012-01-02'))

    organisation = create(:organisation, editions: [
      old_published_corporate_publication,
      new_published_corporate_publication,
      middle_published_corporate_publication,
    ])

    get :index, params: { organisation_id: organisation }

    assert_equal [
      new_published_corporate_publication,
      middle_published_corporate_publication,
      old_published_corporate_publication
    ], assigns(:corporate_publications)
  end

  view_test "should display link to corporate information pages on about-us page" do
    organisation = create(:organisation)
    corporate_information_page = create(:published_corporate_information_page, organisation: organisation)
    draft_corporate_information_page = create(:corporate_information_page, organisation: organisation, corporate_information_page_type_id: CorporateInformationPageType::ComplaintsProcedure.id)
    get :index, params: { organisation_id: organisation }
    assert_select "a[href='#{organisation_corporate_information_page_path(organisation, corporate_information_page.slug)}']"
    refute_select "a[href='#{organisation_corporate_information_page_path(organisation, draft_corporate_information_page.slug)}']"
  end

  view_test "should not display corporate information section on about-us page if there are no corporate publications" do
    organisation = create(:organisation)
    get :index, params: { organisation_id: organisation }
    refute_select "#corporate-information"
  end

  test 'finds unpublishing for a corporate information page' do
    organisation = create(:organisation)
    cip = create(:corporate_information_page, :unpublished, organisation: organisation)
    alternative_url = Whitehall.url_maker.root_url
    cip.unpublishing.update_attributes!(redirect: true, slug: cip.slug, alternative_url: alternative_url)

    get :show, params: { organisation_id: cip.organisation, id: cip.slug }
    assert_response :redirect
    assert_redirected_to alternative_url
  end

  test 'unpublishing is specific to the organisation' do
    organisation = create(:organisation)
    organisation_2 = create(:organisation, slug: 'another_organisation')
    cip = create(:corporate_information_page, :unpublished, organisation: organisation)
    alternative_url = Whitehall.url_maker.root_url
    cip.unpublishing.update_attributes!(redirect: true, slug: cip.slug, alternative_url: alternative_url)
    draft_cip = create(:corporate_information_page, organisation: organisation_2)

    # Even though the Unpublishing has the same slug as the draft CIP, we should
    # only find it for the unpublished one.
    assert_equal draft_cip.slug, cip.unpublishing.slug

    get :show, params: { organisation_id: organisation, id: cip.slug }
    assert_response :redirect

    get :show, params: { organisation_id: organisation_2, id: cip.slug }
    assert_response 404
  end
end
