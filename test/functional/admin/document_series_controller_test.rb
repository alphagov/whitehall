require "test_helper"

class Admin::DocumentSeriesControllerTest < ActionController::TestCase
  setup do
    @organisation = create(:organisation)
    @user = create(:policy_writer, organisation: @organisation)
    login_as @user
  end

  should_be_an_admin_controller

  view_test "GET #new renders document series form" do
    get :new, organisation_id: @organisation

    assert_select "form[action=?]", admin_organisation_document_series_index_path(@organisation) do
      assert_select "input[type=text][name=?]", "document_series[name]"
      assert_select "textarea[name=?]", "document_series[description]"
    end
  end

  test "POST #create saves a the document series to the organisation" do
    post :create, organisation_id: @organisation, document_series: {
          name: "series-name",
          summary: "series-summary",
          description: "series-description"
        }

    assert_equal 1, @organisation.document_series.count
    document_series = @organisation.document_series.first
    assert_equal "series-name", document_series.name
    assert_equal "series-description", document_series.description
    assert_response :redirect
  end

  view_test "POST #create with invalid params re-renders form the with errors" do
    post :create, organisation_id: @organisation, document_series: { name: "" }

    assert_response :success
    assert_equal 0, @organisation.document_series.count

    assert_select "form .field_with_errors input[name=?]", "document_series[name]"
  end

  view_test 'GET #show displays the document series' do
    series = create(:document_series,
      organisation: @organisation,
      name: "series-name",
      description: "description-in-govspeak"
    )

    govspeak_transformation_fixture "description-in-govspeak" => "description-in-html" do
      get :show, organisation_id: @organisation, id: series
    end

    assert_select "h1", "series-name"
    assert_select ".govspeak", "description-in-html"
  end

  test "GET #index redirects to the list of the user's organisation's document series" do
    get :index

    assert_redirected_to admin_organisation_document_series_index_path(@user.organisation)
  end

  test "GET #index redirects to the organisation list page if the user has no organisation" do
    @user.organisation = nil
    @user.save
    get :index

    assert_redirected_to admin_organisations_path
  end

  view_test "GET #edit renders the edit form for the document series" do
    document_series = create(:document_series, organisation: @organisation)

    get :edit, organisation_id: @organisation,
               id: document_series

    assert_select "form[action=?]", admin_organisation_document_series_path(@organisation, document_series) do
      assert_select "input[type=text][name=?]", "document_series[name]"
      assert_select "textarea[name=?]", "document_series[description]"
    end
  end

  test "PUT #update updates the document series" do
    document_series = create(:document_series, organisation: @organisation, name: "old-name")

    put :update, organisation_id: @organisation, id: document_series, document_series: { name: "new-name" }

    assert_equal "new-name", document_series.reload.name
    assert_response :redirect
  end

  test "DELETE #destroy deletes the document series" do
    document_series = create(:document_series, organisation: @organisation)
    delete :destroy, organisation_id: @organisation, id: document_series

    refute DocumentSeries.exists?(document_series)
    assert_response :redirect
  end

  view_test "PUT #update with invalid params re-renders the form with errors" do
    document_series = create(:document_series, organisation: @organisation, name: "old-name")
    put :update, organisation_id: @organisation, id: document_series, document_series: {name: ""}

    assert_equal "old-name", document_series.reload.name

    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "document_series[name]"
    end
  end
end
