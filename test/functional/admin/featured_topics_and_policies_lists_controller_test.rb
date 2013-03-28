require 'test_helper'

class Admin::FeaturedTopicsAndPoliciesListsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  test "GET show fetches the featured topics and policies list for the supplied org" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    get :show, organisation_id: org

    assert_equal featured_topics_and_policies_list, assigns(:featured_topics_and_policies_list)
  end

  test "GET show fetches an unsaved featured topics and policies list for the supplied org if it doesn't already have one" do
    org = create(:organisation)

    get :show, organisation_id: org

    list = assigns(:featured_topics_and_policies_list)
    assert list
    assert_equal org, list.organisation
    refute list.persisted?
  end

  test "PUT update will save the supplied changes to the featured topics and policies list for the supplied org" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: 'Wooo' }

    assert_equal 'Wooo', featured_topics_and_policies_list.reload.summary
  end

  test "PUT update will create a featured topics and policies list for the supplied org if it doesn't already have one" do
    org = create(:organisation)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: 'Wooo' }

    list = assigns(:featured_topics_and_policies_list)
    assert list
    assert_equal org, list.organisation
    assert list.persisted?
    assert_equal 'Wooo', list.summary
  end

  test "PUT update that fails will render the show template" do
    org = create(:organisation)
    featured_topics_and_policies_list = create(:featured_topics_and_policies_list, organisation: org)

    put :update, organisation_id: org, featured_topics_and_policies_list: { summary: '' }

    assert_template :show
  end
end