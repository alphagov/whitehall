require 'test_helper'

class Admin::PromotionalFeaturesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
    @organisation = create(:executive_office)
  end

  should_be_an_admin_controller

  test "GET :index returns a 404 if the organisation is not allowed promotional" do
    organisation = create(:ministerial_department)

    assert_raise ActiveRecord::RecordNotFound do
      get :index, organisation_id: organisation
    end
  end

  test "GET :index loads the promotional organisation and renders the index template" do
    create(:promotional_feature, organisation: @organisation)
    get :index, organisation_id: @organisation

    assert_response :success
    assert_equal @organisation, assigns(:organisation)
    assert_equal @organisation.promotional_features, assigns(:promotional_features)
    assert_template :index
  end

  test "GET :new prepares a promotional feature" do
    get :new, organisation_id: @organisation

    assert_response :success
    assert_equal @organisation, assigns(:organisation)
    assert assigns(:promotional_feature).is_a?(PromotionalFeature)
  end

  test "POST :create saves the new promotional feature and redirects to the show page" do
    post :create, organisation_id: @organisation, promotional_feature: { title: 'Promotional feature title'}

    assert promotional_feature = @organisation.reload.promotional_features.last
    assert_equal 'Promotional feature title', promotional_feature.title
    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, promotional_feature)
  end

  test "GET :show loads the promotional feature belonging to the organisation" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)
    get :show, organisation_id: @organisation, id: promotional_feature

    assert_response :success
    assert_template :show
    assert_equal promotional_feature, assigns(:promotional_feature)
  end

  test "GET :edit loads the promotional feature and renders the template" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)
    get :edit, organisation_id: @organisation, id: promotional_feature

    assert_response :success
    assert_template :edit
    assert_equal promotional_feature, assigns(:promotional_feature)
  end

  test "PUT :update saves the promotional feature and redirects to the show page" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)
    put :update, organisation_id: @organisation, id: promotional_feature, promotional_feature: { title: 'New title' }

    assert_redirected_to admin_organisation_promotional_feature_url(@organisation, promotional_feature)
    assert_equal 'New title', promotional_feature.reload.title
  end

  test "DELETE :destroy deletes the promotional feature" do
    promotional_feature = create(:promotional_feature, organisation: @organisation)
    delete :destroy, organisation_id: @organisation, id: promotional_feature

    assert_redirected_to admin_organisation_promotional_features_url(@organisation)
    refute PromotionalFeature.exists?(promotional_feature)
    assert_equal 'Promotional feature deleted.', flash[:notice]
  end
end
