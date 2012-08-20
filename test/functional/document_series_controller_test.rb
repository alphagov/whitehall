require "test_helper"

class DocumentSeriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'index should redirect to organisations publication' do
    organisation = create(:organisation)

    get :index, organisation_id: organisation

    assert_redirected_to publications_organisation_path(organisation)
  end

  test 'show should display published documents within a series' do
    organisation = create(:organisation)
    series = create(:document_series, organisation: organisation)
    publication = create(:published_publication, document_series: series)
    draft_publication = create(:draft_publication, document_series: series)

    get :show, organisation_id: organisation, id: series

    assert_select_object(publication)
    refute_select_object(draft_publication)
  end
end
