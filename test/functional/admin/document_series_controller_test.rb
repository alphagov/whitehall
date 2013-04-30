require "test_helper"

class Admin::DocumentSeriesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  view_test "new should show fields for creating a series" do
    organisation = create(:organisation)

    get :new, organisation_id: organisation

    assert_select "form[action=?]", admin_organisation_document_series_index_path(organisation) do
      assert_select "input[type=text][name=?]", "document_series[name]"
      assert_select "textarea[name=?]", "document_series[description]"
    end
  end

  test "create should save a new series" do
    organisation = create(:organisation)

    post :create, organisation_id: organisation, document_series: {
          name: "series-name",
          summary: "series-summary",
          description: "series-description"
        }

    assert_equal 1, organisation.document_series.count
    document_series = organisation.document_series.first
    assert_equal "series-name", document_series.name
    assert_equal "series-description", document_series.description
    assert_redirected_to admin_organisation_document_series_path(organisation, document_series)
  end

  view_test "create should allow errors to be corrected" do
    organisation = create(:organisation)

    post :create, organisation_id: organisation, document_series: {name: ""}

    assert_response :success
    assert_equal 0, organisation.document_series.count
    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "document_series[name]"
    end
  end

  view_test 'show should display document series attributes' do
    organisation = create(:organisation, name: "organisation-name")
    series = create(:document_series,
      organisation: organisation,
      name: "series-name",
      description: "description-in-govspeak"
    )

    govspeak_transformation_fixture "description-in-govspeak" => "description-in-html" do
      get :show, organisation_id: organisation, id: series
    end

    assert_select "h1", "series-name"
    assert_select ".description", "description-in-html"
  end

  view_test "show lists all associated editions" do
    document_series = create(:document_series)
    organisation = document_series.organisation
    edition = create(:published_publication, document_series: [document_series])

    get :show, organisation_id: organisation, id: document_series

    assert_select_object(edition)
  end

  view_test "lists all document series" do
    document_series1 = create(:document_series)
    document_series2 = create(:document_series)
    document_series3 = create(:document_series)

    get :index

    assert_select_object(document_series1)
    assert_select_object(document_series2)
    assert_select_object(document_series3)
  end

  view_test "edit should show a form for editing the series" do
    document_series = create(:document_series)
    organisation = document_series.organisation

    get :edit, organisation_id: organisation,
               id: document_series

    form_path = admin_organisation_document_series_path(organisation, document_series)
    assert_select "form[action=?]", form_path do
      assert_select "input[type=text][name=?]", "document_series[name]"
      assert_select "textarea[name=?]", "document_series[description]"
    end
  end

  test "update should update a series" do
    document_series = create(:document_series, name: "old-name")
    organisation = document_series.organisation

    put :update, organisation_id: organisation, id: document_series, document_series: {
      name: "new-name",
      description: "new-description"
    }

    assert_equal "new-name", document_series.reload.name
    assert_equal "new-description", document_series.reload.description
    assert_redirected_to admin_organisation_document_series_path(organisation, document_series)
  end

  test "delete should delete a series" do
    document_series = create(:document_series, name: "old-name")
    organisation = document_series.organisation

    delete :destroy, organisation_id: organisation, id: document_series

    assert_redirected_to admin_document_series_index_path
  end

  view_test "update should show errors updating a series" do
    document_series = create(:document_series, name: "old-name")
    organisation = document_series.organisation

    put :update, organisation_id: organisation,
                 id: document_series,
                 document_series: {name: ""}

    assert_equal "old-name", document_series.reload.name

    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "document_series[name]"
    end
  end
end
