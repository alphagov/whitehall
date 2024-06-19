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

  test "GDS Admin users should be able to GET :new_documents_by_organisation" do
    get :new_documents_by_organisation
    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :new_documents_by_organisation" do
    login_as :writer

    get :new_documents_by_organisation
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_documents_by_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation")

    post :search_documents_by_organisation, params: { organisation_slug: "an-existing-organisation" }

    assert_redirected_to admin_bulk_republishing_documents_by_organisation_confirm_path("an-existing-organisation")
  end

  test "GDS Admin users should be redirected back to :new_documents_by_organisation when trying to POST :search_documents_by_organisation with a nonexistent organisation slug" do
    post :search_documents_by_organisation, params: { organisation_slug: "not-an-existing-organisation" }

    assert_redirected_to admin_bulk_republishing_documents_by_organisation_new_path
    assert_equal "Organisation with slug 'not-an-existing-organisation' not found", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_documents_by_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    login_as :writer

    post :search_documents_by_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_documents_by_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation")

    get :confirm_documents_by_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_documents_by_organisation with a nonexistent organisation slug" do
    get :confirm_documents_by_organisation, params: { organisation_slug: "not-an-existing-organisation" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to access :confirm_documents_by_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    login_as :writer

    get :confirm_documents_by_organisation, params: { organisation_slug: "organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_documents_by_organisation with an existing organisation slug and a reason, creating a RepublishingEvent for the current user" do
    organisation = create(:organisation, id: "1234", slug: "an-existing-organisation", name: "An Existing Organisation")

    BulkRepublisher.any_instance.expects(:republish_all_documents_by_organisation).with(organisation).once

    post :republish_documents_by_organisation, params: { organisation_slug: "an-existing-organisation", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal current_user, newly_created_event.user
    assert_equal "this needs republishing", newly_created_event.reason
    assert_equal "All documents by organisation 'An Existing Organisation' have been queued for republishing", newly_created_event.action
    assert_equal true, newly_created_event.bulk
    assert_equal "all_documents_by_organisation", newly_created_event.bulk_content_type
    assert_equal "1234", newly_created_event.organisation_id

    assert_redirected_to admin_republishing_index_path
    assert_equal "All documents by organisation 'An Existing Organisation' have been queued for republishing", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_documents_by_organisation without a `reason` and be sent back to the confirm page" do
    organisation = create(:organisation, slug: "an-existing-organisation", name: "An Existing Organisation")

    BulkRepublisher.any_instance.expects(:republish_all_documents_by_organisation).with(organisation).never

    post :republish_documents_by_organisation, params: { organisation_slug: "an-existing-organisation", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_documents_by_organisation"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_documents_by_organisation with a nonexistent organisation slug" do
    BulkRepublisher.any_instance.expects(:republish_all_documents_by_organisation).never

    post :republish_documents_by_organisation, params: { organisation_slug: "not-an-existing-organisation" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_documents_by_organisation" do
    organisation = create(:organisation, slug: "an-existing-organisation", name: "An Existing Organisation")

    BulkRepublisher.any_instance.expects(:republish_all_documents_by_organisation).with(organisation).never

    login_as :writer

    post :republish_documents_by_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :new_documents_by_content_ids" do
    get :new_documents_by_content_ids
    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :new_documents_by_content_ids" do
    login_as :writer

    get :new_documents_by_content_ids
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_documents_by_content_ids with valid document content IDs" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    post :search_documents_by_content_ids, params: { content_ids: "abc-123, def-456" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_confirm_path("abc-123, def-456")
  end

  test "GDS Admin users should be redirected back to :new_documents_by_content_ids when trying to POST :search_documents_by_content_ids with no content IDs" do
    post :search_documents_by_content_ids, params: { content_ids: "" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_new_path
    assert_equal "No content IDs provided", flash[:alert]
  end

  test "GDS Admin users should be redirected back to :new_documents_by_content_ids when trying to POST :search_documents_by_content_ids with invalid content IDs" do
    post :search_documents_by_content_ids, params: { content_ids: "this is not valid" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_new_path
    assert_equal "Unable to find document(s) with the following content IDs: 'this', 'is', 'not', and 'valid'", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_documents_by_content_ids" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    login_as :writer

    post :search_documents_by_content_ids, params: { content_ids: "abc-123, def-456" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_documents_by_content_ids with valid document content IDs" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    post :confirm_documents_by_content_ids, params: { content_ids: "abc-123, def-456" }

    assert_response :ok
  end

  test "GDS Admin users should be redirected back to :new_documents_by_content_ids when trying to GET :confirm_documents_by_content_ids with no content IDs" do
    post :confirm_documents_by_content_ids, params: { content_ids: "" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_new_path
    assert_equal "No content IDs provided", flash[:alert]
  end

  test "GDS Admin users should be redirected back to :new_documents_by_content_ids when trying to GET :confirm_documents_by_content_ids with invalid content IDs" do
    post :confirm_documents_by_content_ids, params: { content_ids: "this is not valid" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_new_path
    assert_equal "Unable to find document(s) with the following content IDs: 'this', 'is', 'not', and 'valid'", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to GET :confirm_documents_by_content_ids" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    login_as :writer

    post :confirm_documents_by_content_ids, params: { content_ids: "abc-123, def-456" }

    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_documents_by_content_ids with valid document content IDs and a reason, creating a RepublishingEvent for the current user" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    BulkRepublisher.any_instance.expects(:republish_all_documents_by_ids).with([1, 2]).once

    post :republish_documents_by_content_ids, params: { content_ids: "abc-123, def-456", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal current_user, newly_created_event.user
    assert_equal "this needs republishing", newly_created_event.reason
    assert_equal "All documents by content IDs 'abc-123' and 'def-456' have been queued for republishing", newly_created_event.action
    assert_equal true, newly_created_event.bulk
    assert_equal "all_documents_by_content_ids", newly_created_event.bulk_content_type
    assert_equal %w[abc-123 def-456], newly_created_event.content_ids

    assert_redirected_to admin_republishing_index_path
    assert_equal "All documents by content IDs 'abc-123' and 'def-456' have been queued for republishing", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_documents_by_content_ids without a reason and be sent back to the confirm page" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    BulkRepublisher.any_instance.expects(:republish_all_documents_by_ids).with([1, 2]).never

    post :republish_documents_by_content_ids, params: { content_ids: "abc-123, def-456", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_documents_by_content_ids"
  end

  test "GDS Admin users should be redirected back to :new_documents_by_content_ids when trying to POST :republish_documents_by_content_ids with no content IDs" do
    BulkRepublisher.any_instance.expects(:republish_all_documents_by_ids).with([1, 2]).never

    post :republish_documents_by_content_ids, params: { content_ids: "", reason: "this needs republishing" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_new_path
    assert_equal "No content IDs provided", flash[:alert]
  end

  test "GDS Admin users should be redirected back to :new_documents_by_content_ids when trying to POST :republish_documents_by_content_ids with invalid content IDs" do
    post :republish_documents_by_content_ids, params: { content_ids: "this is not valid", reason: "this needs republishing" }

    assert_redirected_to admin_bulk_republishing_documents_by_content_ids_new_path
    assert_equal "Unable to find document(s) with the following content IDs: 'this', 'is', 'not', and 'valid'", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :republish_documents_by_content_ids" do
    create(:document, id: 1, content_id: "abc-123")
    create(:document, id: 2, content_id: "def-456")

    BulkRepublisher.any_instance.expects(:republish_all_documents_by_ids).with([1, 2]).never

    login_as :writer

    post :republish_documents_by_content_ids, params: { content_ids: "abc-123, def-456", reason: "this needs republishing" }
    assert_response :forbidden
  end
end
