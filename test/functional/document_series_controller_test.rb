require "test_helper"

class DocumentSeriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'index should redirect to organisations publication' do
    organisation = create(:organisation)

    get :index, organisation_id: organisation

    assert_redirected_to publications_path(departments: [organisation])
  end

  test 'show should display published publications within the series' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication = create(:published_publication, document_series: series)
    draft_publication = create(:draft_publication, document_series: series)

    get :show, organisation_id: organisation, id: series

    assert_select_object(publication)
    refute_select_object(draft_publication)
  end

  test 'show should display published statistical data sets within the series' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    statistical_data_set = create(:published_statistical_data_set, document_series: series)
    draft_statistical_data_set = create(:draft_statistical_data_set, document_series: series)

    get :show, organisation_id: organisation, id: series

    assert_select_object(statistical_data_set)
    refute_select_object(draft_statistical_data_set)
  end

  test 'show should display document series attributes' do
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
    assert_select ".description", "In this series\n        description-in-html"
  end
end
