require "test_helper"

class DocumentSeriesControllerTest < ActionController::TestCase
  should_be_a_public_facing_controller

  test 'index should redirect to organisations publication' do
    organisation = create(:organisation)

    get :index, organisation_id: organisation

    assert_redirected_to publications_path(departments: [organisation])
  end

  view_test 'GET #show displays the document series and its published editions' do
    organisation = create(:organisation)
    series = create(:document_series, :with_group,
      organisation: organisation,
      name: "series-name",
      description: "description-in-govspeak",
      summary: "series-summary"
    )
    publication = create(:published_publication)
    draft_publication = create(:draft_publication)
    series.groups.first.documents = [publication.document, draft_publication.document]

    govspeak_transformation_fixture "description-in-govspeak" => "description-in-html" do
      get :show, organisation_id: organisation, id: series
    end

    assert_select "h1", "series-name"
    assert_select ".description", "description-in-html"
    assert_equal "series-summary", assigns(:meta_description)
    assert_select_object(publication)
    refute_select_object(draft_publication)
  end

  test "GET #show sets Cache-Control: max-age to the time of the next scheduled publication in the series" do
    user = login_as(:departmental_editor)
    organisation = create(:organisation)
    series = create(:document_series, :with_group, organisation: organisation)
    publication = create(:draft_publication, scheduled_publication: Time.zone.now + Whitehall.default_cache_max_age * 2)
    publication.reload.schedule_as(user, force: true)
    series.groups.first.documents << publication.document

    Timecop.freeze(Time.zone.now + Whitehall.default_cache_max_age * 1.5) do
      get :show, organisation_id: organisation, id: series
    end

    assert_cache_control("max-age=#{Whitehall.default_cache_max_age/2}")
  end
end
