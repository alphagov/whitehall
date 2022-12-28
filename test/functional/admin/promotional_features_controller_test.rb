require "test_helper"

class Admin::PromotionalFeaturesControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @organisation = create(:executive_office)
  end

  should_be_an_admin_controller

  test "GET :index returns a 404 if the organisation is not allowed promotional" do
    organisation = create(:ministerial_department)

    assert_raise ActiveRecord::RecordNotFound do
      get :index, params: { organisation_id: organisation }
    end
  end

  test "GET :index loads the promotional organisation and renders the index template" do
    create(:promotional_feature, organisation: @organisation)
    get :index, params: { organisation_id: @organisation }

    assert_response :success
    assert_equal @organisation, assigns(:organisation)
    assert_equal @organisation.reload.promotional_features, assigns(:promotional_features)
    assert_template :index
  end

  test "GET :new prepares a promotional feature" do
    get :new, params: { organisation_id: @organisation }

    assert_response :success
    assert_equal @organisation, assigns(:organisation)
    assert assigns(:promotional_feature).is_a?(PromotionalFeature)
  end

  test "POST :create saves the new promotional feature, republishes the organisation to the PublishingApi and redirects to the show page" do
    Whitehall::PublishingApi.expects(:republish_async).once.with(@organisation)

    post :create, params: { organisation_id: @organisation, promotional_feature: { title: "Promotional feature title" } }

    assert promotional_feature = @organisation.reload.promotional_features.last
    assert_equal "Promotional feature title", promotional_feature.title
    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, promotional_feature)
  end

  test "GET :show loads the promotional feature belonging to the organisation" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)
    get :show, params: { organisation_id: @organisation, id: promotional_feature }

    assert_response :success
    assert_template :show
    assert_equal promotional_feature, assigns(:promotional_feature)
  end

  test "GET :edit loads the promotional feature and renders the template" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)
    get :edit, params: { organisation_id: @organisation, id: promotional_feature }

    assert_response :success
    assert_template :edit
    assert_equal promotional_feature, assigns(:promotional_feature)
  end

  test "PUT :update saves the promotional feature, republishes the organisation to the PublishingApi and redirects to the show page" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)

    Whitehall::PublishingApi.expects(:republish_async).once.with(@organisation)

    put :update, params: { organisation_id: @organisation, id: promotional_feature, promotional_feature: { title: "New title" } }

    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, promotional_feature)
    assert_equal "New title", promotional_feature.reload.title
  end

  test "DELETE :destroy deletes the promotional feature and republishes the organisation to the PublishingApi" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)

    Whitehall::PublishingApi.expects(:republish_async).once.with(@organisation)

    delete :destroy, params: { organisation_id: @organisation, id: promotional_feature }

    assert_redirected_to admin_organisation_promotional_features_url(@organisation)
    assert_not PromotionalFeature.exists?(promotional_feature.id)
    assert_equal "Promotional feature deleted.", flash[:notice]
  end

  test "GET :reorder loads the promotional feature belonging to the organisation" do
    promotional_feature1 = create(:promotional_feature, organisation: @organisation)
    promotional_feature2 = create(:promotional_feature, organisation: @organisation)

    get :reorder, params: { organisation_id: @organisation }

    assert_response :success
    assert_template :reorder
    assert_equal [promotional_feature1, promotional_feature2], assigns(:promotional_features)
  end

  test "GET :reorder redirects to the promotional features index page when the org has less than 2 promotional features" do
    create(:promotional_feature, organisation: @organisation)

    get :reorder, params: { organisation_id: @organisation }

    assert_redirected_to admin_organisation_promotional_features_path(@organisation)
  end

  test "PATCH on :update_order reorders the promotional_features and republishes the organisation" do
    Organisation.stubs(:allowed_promotional).returns(organisations_array = mock)
    organisations_array.expects(:find).with(@organisation.slug).returns(@organisation)
    @organisation.expects(:reorder_promotional_features).with do |value|
      value["2"] == "1" && value["1"] == "2"
    end
    Whitehall::PublishingApi.expects(:republish_async).once.with(@organisation)

    put :update_order, params: {
      organisation_id: @organisation,
      ordering: {
        "2": "1",
        "1": "2",
      },
    }

    assert_redirected_to admin_organisation_promotional_features_path(@organisation)
    assert_equal "Promotional features reordered successfully", flash[:notice]
  end
end
