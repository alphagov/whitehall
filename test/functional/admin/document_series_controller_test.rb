require "test_helper"

class Admin::DocumentSeriesControllerTest < ActionController::TestCase
  setup do
    @organisation_1 = create(:organisation)

    @user = create(:policy_writer)
    login_as @user
  end

  should_be_an_admin_controller
  should_allow_related_policies_for :document_series
  should_allow_organisations_for :document_series

  ### Describing #show ###

  view_test 'GET #show displays the document series' do
    series = create(:document_series,
      title: "series-title",
      summary: "the summary"
    )

    get :show, id: series

    assert_select "h1", "series-title"
    assert_select ".summary", "the summary"
  end


  ### Describing #new ###

  view_test "GET #new renders document series form" do
    get :new

    assert_select "form[action=?]", admin_document_series_index_path do
      assert_select "input[type=text][name=?]", "edition[title]"
      assert_select "textarea[name=?]", "edition[summary]"
      assert_select "textarea[name=?]", "edition[body]"
    end
  end


  ### Describing #create ###

  test "POST #create saves the document series" do
    post :create, edition: {
          title: "series-title",
          summary: "series-summary",
          body: "series-body",
          lead_organisation_ids: [@organisation_1.id]
        }

    assert_equal 1, DocumentSeries.count
    document_series = DocumentSeries.first
    assert_equal "series-title", document_series.title
    assert_equal "series-summary", document_series.summary
    assert_equal "series-body", document_series.body
    assert document_series.groups.present?, 'should have a group'
  end

  view_test "POST #create with invalid params re-renders form the with errors" do
    post :create, edition: { title: "" }

    assert_response :success
    assert_equal 0, DocumentSeries.count

    assert_select "form .field_with_errors input[name=?]", "edition[title]"
  end



  ### Describing #edit ###

  view_test "GET #edit renders the edit form for the document series" do
    document_series = create(:document_series)

    get :edit, id: document_series

    assert_select "form[action=?]", admin_document_series_path(document_series) do
      assert_select "input[name='edition[slug]'][value=?]", document_series.slug
      assert_select "input[name='edition[title]'][value=?]", document_series.title
      assert_select "textarea[name='edition[summary]']", text: document_series.summary
      assert_select "textarea[name='edition[body]']", text: document_series.body
    end
  end


  ### Describing #update ###

  test "PUT #update updates the document series" do
    document_series = create(:document_series, title: "old-title")

    put :update, id: document_series, edition: { title: "new-title" }

    assert_equal "new-title", document_series.reload.title
    assert_response :redirect
  end

  view_test "PUT #update with invalid params re-renders the form with errors" do
    document_series = create(:document_series, title: "old-title")
    put :update, id: document_series, edition: {title: ""}

    assert_equal "old-title", document_series.reload.title

    assert_select "form" do
      assert_select ".field_with_errors input[name=?]", "edition[title]"
    end
  end


  ### Describing #destroy ###
  test "Delete does some funky stuff depending on publication state now, test it" do
    assert false, "Pending"
  end

  test "DELETE #destroy deletes the document series" do
    document_series = create(:document_series)
    delete :destroy, id: document_series

    refute DocumentSeries.exists?(document_series)
    assert_response :redirect
  end

end
