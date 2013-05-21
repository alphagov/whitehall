require "test_helper"

class DocumentSeriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'index should redirect to organisations publication' do
    organisation = create(:organisation)

    get :index, organisation_id: organisation

    assert_redirected_to publications_path(departments: [organisation])
  end

  view_test 'show should display published publications within the series' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication = create(:published_publication, document_series: [series])
    draft_publication = create(:draft_publication, document_series: [series])

    get :show, organisation_id: organisation, id: series

    assert_select_object(publication)
    refute_select_object(draft_publication)
  end

  test 'show should display publications in order of published date' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication_middle = create(:published_publication, document_series: [series], publication_date: Date.parse('2011-05-01'))
    publication_old = create(:published_publication, document_series: [series], publication_date: Date.parse('2011-01-01'))
    publication_new = create(:published_publication, document_series: [series], publication_date: Date.parse('2012-01-01'))

    get :show, organisation_id: organisation, id: series

    assert_equal [
      publication_new,
      publication_middle,
      publication_old
    ], assigns(:published_publications).object
  end

  view_test 'show should display published statistical data sets within the series' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    statistical_data_set = create(:published_statistical_data_set, document_series: [series])
    draft_statistical_data_set = create(:draft_statistical_data_set, document_series: [series])

    get :show, organisation_id: organisation, id: series

    assert_select_object(statistical_data_set)
    refute_select_object(draft_statistical_data_set)
  end

  test 'show should display statistical data sets in order of publication' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    old_statistical_data_set = create(:published_statistical_data_set, document_series: [series], first_published_at: 3.days.ago)
    new_statistical_data_set = create(:published_statistical_data_set, document_series: [series], first_published_at: 1.days.ago)
    middle_statistical_data_set = create(:published_statistical_data_set, document_series: [series], first_published_at: 2.days.ago)

    get :show, organisation_id: organisation, id: series

    assert_equal [
      new_statistical_data_set,
      middle_statistical_data_set,
      old_statistical_data_set
    ], assigns(:published_statistical_data_sets).object
  end

  view_test 'show should display document series attributes' do
    organisation = create(:organisation)
    series = create(:document_series,
      organisation: organisation,
      name: "series-name",
      description: "description-in-govspeak"
    )

    govspeak_transformation_fixture "description-in-govspeak" => "description-in-html" do
      get :show, organisation_id: organisation, id: series
    end

    assert_select "h1 .title", "series-name"
    assert_select ".description", "description-in-html"
  end

  test "show sets Cache-Control: max-age to the time of the next scheduled publication in the series" do
    user = login_as(:departmental_editor)
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication = create(:draft_publication, document_series: [series], scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    publication.schedule_as(user, force: true)

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, organisation_id: organisation, id: series
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end

end
