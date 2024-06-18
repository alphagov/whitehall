require "test_helper"

class Admin::BulkRepublishingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "GDS Admin users should be able to GET :confirm with a valid parameterless bulk content type" do
    get :confirm, params: { bulk_content_type: "all-published-organisation-about-us-pages" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm with an invalid parameterless bulk content type" do
    get :confirm, params: { bulk_content_type: "fish" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm" do
    login_as :writer

    get :confirm, params: { bulk_content_type: "all-published-organisation-about-us-pages" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish with a valid bulk content type and a reason, creating a RepublishingEvent for the current user" do
    BulkRepublisher.any_instance.expects(:republish_all_published_organisation_about_us_pages).once

    post :republish, params: { bulk_content_type: "all-published-organisation-about-us-pages", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "All published organisation 'About us' pages have been queued for republishing"
    assert_equal newly_created_event.bulk, true
    assert_equal newly_created_event.bulk_content_type, "all_published_organisation_about_us_pages"

    assert_redirected_to admin_republishing_index_path
    assert_equal "All published organisation 'About us' pages have been queued for republishing", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish without a `reason` and be sent back to the confirm page" do
    BulkRepublisher.expects(:new).never

    post :republish, params: { bulk_content_type: "all-published-organisation-about-us-pages", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish with an invalid bulk content type" do
    BulkRepublisher.expects(:new).never

    post :republish, params: { bulk_content_type: "not-a-bulk-content-type", reason: "this needs republishing" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish" do
    BulkRepublisher.expects(:new).never

    login_as :writer

    post :republish, params: { bulk_content_type: "all-published-organisation-about-us-pages", reason: "this needs republishing" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :new_by_type" do
    get :new_by_type
    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :new_by_type" do
    login_as :writer

    get :new_by_type
    assert_response :forbidden
  end

  test "GDS Admin users should be redirected to :confirm_by_type on POST :new_by_type" do
    post :new_by_type_redirect, params: { content_type: "organisation" }
    assert_redirected_to admin_bulk_republishing_by_type_confirm_path(content_type: "organisation")
  end

  test "Non-GDS Admin users should not be able to POST :new_by_type" do
    login_as :writer

    post :new_by_type_redirect, params: { content_type: "organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_by_type with a valid content type" do
    get :confirm_by_type, params: { content_type: "organisation" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_by_type with an invalid content type" do
    get :confirm_by_type, params: { content_type: "not-a-content-type" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to access :confirm_by_type" do
    login_as :writer

    get :confirm_by_type, params: { content_type: "organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_by_type with a valid content type and a reason, creating a RepublishingEvent for the current user" do
    BulkRepublisher.any_instance.expects(:republish_all_by_type).with("Organisation").once

    post :republish_by_type, params: { content_type: "organisation", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "All by type 'Organisation' have been queued for republishing"
    assert_equal newly_created_event.bulk, true
    assert_equal newly_created_event.bulk_content_type, "all_by_type"
    assert_equal newly_created_event.content_type, "Organisation"

    assert_redirected_to admin_republishing_index_path
    assert_equal "All by type 'Organisation' have been queued for republishing", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_by_type without a `reason` and be sent back to the confirm page" do
    BulkRepublisher.expects(:new).never

    post :republish_by_type, params: { content_type: "organisation", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_by_type"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_by_type with an invalid content type" do
    BulkRepublisher.expects(:new).never

    post :republish_by_type, params: { content_type: "not-a-content-type", reason: "this needs republishing" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_by_type" do
    BulkRepublisher.expects(:new).never

    login_as :writer

    post :republish_by_type, params: { content_type: "organisation", reason: "this needs republishing" }
    assert_response :forbidden
  end
end
