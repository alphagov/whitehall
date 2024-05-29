require "test_helper"

class Admin::BulkRepublishingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
  end

  should_be_an_admin_controller

  test "GDS Admin users should be able to GET :confirm_all with a valid parameterless bulk content type" do
    get :confirm_all, params: { bulk_content_type: "all-organisation-about-us-pages" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_all with an invalid parameterless bulk content type" do
    get :confirm_all, params: { bulk_content_type: "fish" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_all" do
    login_as :writer

    get :confirm_all, params: { bulk_content_type: "all-organisation-about-us-pages" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_all_organisation_about_us_pages, creating a RepublishingEvent for the current user" do
    BulkRepublisher.any_instance.expects(:republish_all_organisation_about_us_pages).once

    post :republish_all_organisation_about_us_pages, params: { reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "All organisation 'About Us' pages have been queued for republishing"
    assert_equal newly_created_event.bulk, true
    assert_equal newly_created_event.bulk_content_type, "all_organisation_about_us_pages"

    assert_redirected_to admin_republishing_index_path
    assert_equal "All organisation 'About Us' pages have been queued for republishing", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_all_organisation_about_us_pages without a `reason` and be sent back to the confirm_all page" do
    BulkRepublisher.any_instance.expects(:republish_all_organisation_about_us_pages).never

    post :republish_all_organisation_about_us_pages, params: { reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_all"
  end

  test "Non-GDS Admin users should not be able to POST :republish_all_organisation_about_us_pages" do
    login_as :writer

    post :republish_all_organisation_about_us_pages, params: { reason: "this needs republishing" }
    assert_response :forbidden
  end
end
