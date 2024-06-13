require "test_helper"

class Admin::RepublishingControllerTest < ActionController::TestCase
  setup do
    login_as :gds_admin
    create(:ministerial_role, name: "Prime Minister", cabinet_member: true)
  end

  should_be_an_admin_controller

  view_test "GDS Admin users should be able to GET :index and see links to republishable content" do
    get :index

    assert_select ".govuk-table:nth-of-type(1) .govuk-table__cell:nth-child(1) a[href='https://www.test.gov.uk/government/history/past-prime-ministers']", text: "Past Prime Ministers"
    assert_select ".govuk-table:nth-of-type(1) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/page/past-prime-ministers/confirm']", text: "Republish the 'Past Prime Ministers' page"

    assert_select ".govuk-table:nth-of-type(2) .govuk-table__body .govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/organisation/find']", text: "Republish an organisation"
    assert_select ".govuk-table:nth-of-type(2) .govuk-table__body .govuk-table__row:nth-child(2) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/person/find']", text: "Republish a person"
    assert_select ".govuk-table:nth-of-type(2) .govuk-table__body .govuk-table__row:nth-child(3) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/role/find']", text: "Republish a role"
    assert_select ".govuk-table:nth-of-type(2) .govuk-table__body .govuk-table__row:nth-child(4) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/document/find']", text: "Republish a document"

    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(1) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/all-documents/confirm']", text: "Republish all documents"
    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(2) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/all-documents-with-pre-publication-editions/confirm']", text: "Republish all documents with pre-publication editions"
    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(3) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/all-documents-with-pre-publication-editions-with-html-attachments/confirm']", text: "Republish all documents with pre-publication editions with HTML attachments"
    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(4) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/all-documents-with-publicly-visible-editions-with-attachments/confirm']", text: "Republish all documents with publicly-visible editions with attachments"
    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(5) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/all-documents-with-publicly-visible-editions-with-html-attachments/confirm']", text: "Republish all documents with publicly-visible editions with HTML attachments"
    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(6) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/all-published-organisation-about-us-pages/confirm']", text: "Republish all published organisation 'About us' pages"
    assert_select ".govuk-table:nth-of-type(3) .govuk-table__body .govuk-table__row:nth-child(7) .govuk-table__cell:nth-child(2) a[href='/government/admin/republishing/bulk/by-type/new']", text: "Republish all by type"

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :index" do
    login_as :writer

    get :index
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_page with a republishable page slug" do
    get :confirm_page, params: { page_slug: "past-prime-ministers" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_page with an unregistered page slug" do
    get :confirm_page, params: { page_slug: "not-republishable" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_page" do
    login_as :writer

    get :confirm_page, params: { page_slug: "past-prime-ministers" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_page with a republishable page slug, creating a RepublishingEvent for the current user" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").once

    post :republish_page, params: { page_slug: "past-prime-ministers", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "The page 'Past Prime Ministers' has been scheduled for republishing"
    assert_equal newly_created_event.content_id, PublishingApi::HistoricalAccountsIndexPresenter.new.content_id

    assert_redirected_to admin_republishing_index_path
    assert_equal "The page 'Past Prime Ministers' has been scheduled for republishing", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish page without a `reason` and be sent back to the confirm page" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").never

    post :republish_page, params: { page_slug: "past-prime-ministers", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_page"
  end

  def enable_reshuffle_mode!
    create(:sitewide_setting, key: :minister_reshuffle_mode, on: true)
  end

  test "GDS Admin users should encounter an error when trying to POST :republish page with the ministers index page when in reshuffle mode" do
    enable_reshuffle_mode!
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::MinistersIndexPresenter").never

    post :republish_page, params: { page_slug: "ministers", reason: "Foo" }

    assert_equal "Cannot republish ministers page while in reshuffle mode", flash[:alert]
    assert_redirected_to admin_republishing_index_path
  end

  test "GDS Admin users should encounter an error when trying to POST :republish page with the 'how government works' page when in reshuffle mode" do
    enable_reshuffle_mode!
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HowGovernmentWorksPresenter").never

    post :republish_page, params: { page_slug: "how-government-works", reason: "Foo" }

    assert_equal "Cannot republish how-government-works page while in reshuffle mode", flash[:alert]
    assert_redirected_to admin_republishing_index_path
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_page with an unregistered page slug" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").never

    post :republish_page, params: { page_slug: "not-republishable" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_page" do
    PresentPageToPublishingApiWorker.expects(:perform_async).with("PublishingApi::HistoricalAccountsIndexPresenter").never

    login_as :writer

    post :republish_page, params: { page_slug: "past-prime-ministers" }
    assert_response :forbidden
  end

  view_test "GDS Admin users should be able to GET :find_organisation" do
    get :find_organisation

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :find_organisation" do
    login_as :writer

    get :find_organisation
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation")

    post :search_organisation, params: { organisation_slug: "an-existing-organisation" }

    assert_redirected_to admin_republishing_organisation_confirm_path("an-existing-organisation")
  end

  test "GDS Admin users should be redirected back to :find_organisation when trying to POST :search_organisation with a nonexistent organisation slug" do
    post :search_organisation, params: { organisation_slug: "not-an-existing-organisation" }

    assert_redirected_to admin_republishing_organisation_find_path
    assert_equal "Organisation with slug 'not-an-existing-organisation' not found", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    login_as :writer

    post :search_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_organisation with an existing organisation slug" do
    create(:organisation, slug: "an-existing-organisation")

    get :confirm_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_organisation with a nonexistent organisation slug" do
    get :confirm_organisation, params: { organisation_slug: "not-an-existing-organisation" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    login_as :writer

    get :confirm_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_organisation with an existing organisation slug, creating a RepublishingEvent for the current user" do
    create(:organisation, slug: "an-existing-organisation", name: "An Existing Organisation", content_id: "6de2fd22-4a87-49b7-be49-915f12dfe6fe")

    Organisation.any_instance.expects(:publish_to_publishing_api).once

    post :republish_organisation, params: { organisation_slug: "an-existing-organisation", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "The organisation 'An Existing Organisation' has been republished"
    assert_equal newly_created_event.content_id, "6de2fd22-4a87-49b7-be49-915f12dfe6fe"

    assert_redirected_to admin_republishing_index_path
    assert_equal "The organisation 'An Existing Organisation' has been republished", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_organisation without a `reason` and be sent back to the confirm page" do
    create(:organisation, slug: "an-existing-organisation", name: "An Existing Organisation")

    Organisation.any_instance.expects(:publish_to_publishing_api).never

    post :republish_organisation, params: { organisation_slug: "an-existing-organisation", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_organisation"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_organisation with a nonexistent organisation slug" do
    Organisation.any_instance.expects(:publish_to_publishing_api).never

    post :republish_organisation, params: { organisation_slug: "not-an-existing-organisation" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_organisation" do
    create(:organisation, slug: "an-existing-organisation")

    Organisation.any_instance.expects(:publish_to_publishing_api).never

    login_as :writer

    post :republish_organisation, params: { organisation_slug: "an-existing-organisation" }
    assert_response :forbidden
  end

  view_test "GDS Admin users should be able to GET :find_person" do
    get :find_person

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :find_person" do
    login_as :writer

    get :find_person
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_person with an existing person slug" do
    create(:person, slug: "existing-person")

    post :search_person, params: { person_slug: "existing-person" }

    assert_redirected_to admin_republishing_person_confirm_path("existing-person")
  end

  test "GDS Admin users should be redirected back to :find_person when trying to POST :search_person with a nonexistent person slug" do
    post :search_person, params: { person_slug: "nonexistent-person" }

    assert_redirected_to admin_republishing_person_find_path
    assert_equal "Person with slug 'nonexistent-person' not found", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_person" do
    create(:person, slug: "existing-person")

    login_as :writer

    post :search_person, params: { person_slug: "existing-person" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_person with an existing person slug" do
    create(:person, slug: "existing-person")

    get :confirm_person, params: { person_slug: "existing-person" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_person with a nonexistent person slug" do
    get :confirm_person, params: { person_slug: "nonexistent-person" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_person" do
    create(:person, slug: "existing-person")

    login_as :writer

    get :confirm_person, params: { person_slug: "existing-person" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_person with an existing person slug, creating a RepublishingEvent for the current user" do
    create(:person, slug: "existing-person", forename: "Existing", surname: "Person", content_id: "6de2fd22-4a87-49b7-be49-915f12dfe6fe")

    Person.any_instance.expects(:publish_to_publishing_api).once

    post :republish_person, params: { person_slug: "existing-person", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "The person 'Existing Person' has been republished"
    assert_equal newly_created_event.content_id, "6de2fd22-4a87-49b7-be49-915f12dfe6fe"

    assert_redirected_to admin_republishing_index_path
    assert_equal "The person 'Existing Person' has been republished", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_person without a `reason` and be sent back to the confirm page" do
    create(:person, slug: "existing-person", forename: "Existing", surname: "Person")

    Person.any_instance.expects(:publish_to_publishing_api).never

    post :republish_person, params: { person_slug: "existing-person", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_person"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_person with a nonexistent person slug" do
    Person.any_instance.expects(:publish_to_publishing_api).never

    post :republish_person, params: { person_slug: "nonexistent-person" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_person" do
    create(:person, slug: "existing-person")

    Person.any_instance.expects(:publish_to_publishing_api).never

    login_as :writer

    post :republish_person, params: { person_slug: "existing-person" }
    assert_response :forbidden
  end

  view_test "GDS Admin users should be able to GET :find_role" do
    get :find_role

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :find_role" do
    login_as :writer

    get :find_role
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_role with an existing role slug" do
    create(:role, slug: "an-existing-role")

    post :search_role, params: { role_slug: "an-existing-role" }

    assert_redirected_to admin_republishing_role_confirm_path("an-existing-role")
  end

  test "GDS Admin users should be redirected back to :find_role when trying to POST :search_role with a nonexistent role slug" do
    post :search_role, params: { role_slug: "not-an-existing-role" }

    assert_redirected_to admin_republishing_role_find_path
    assert_equal "Role with slug 'not-an-existing-role' not found", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_role" do
    create(:role, slug: "an-existing-role")

    login_as :writer

    post :search_role, params: { role_slug: "an-existing-role" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_role with an existing role slug" do
    create(:role, slug: "an-existing-role")

    get :confirm_role, params: { role_slug: "an-existing-role" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_role with a nonexistent role slug" do
    get :confirm_role, params: { role_slug: "not-an-existing-role" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_role" do
    create(:role, slug: "an-existing-role")

    login_as :writer

    get :confirm_role, params: { role_slug: "an-existing-role" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_role with an existing role slug, creating a RepublishingEvent for the current user" do
    create(:role, slug: "an-existing-role", name: "An Existing Role", content_id: "6de2fd22-4a87-49b7-be49-915f12dfe6fe")

    Role.any_instance.expects(:publish_to_publishing_api).once

    post :republish_role, params: { role_slug: "an-existing-role", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "The role 'An Existing Role' has been republished"
    assert_equal newly_created_event.content_id, "6de2fd22-4a87-49b7-be49-915f12dfe6fe"

    assert_redirected_to admin_republishing_index_path
    assert_equal "The role 'An Existing Role' has been republished", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_role without a `reason` and be sent back to the confirm page" do
    create(:role, slug: "an-existing-role", name: "An Existing Role")

    Role.any_instance.expects(:publish_to_publishing_api).never

    post :republish_role, params: { role_slug: "an-existing-role", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_role"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_role with a nonexistent role slug" do
    Role.any_instance.expects(:publish_to_publishing_api).never

    post :republish_role, params: { role_slug: "not-an-existing-role" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_role" do
    create(:role, slug: "an-existing-role")

    Role.any_instance.expects(:publish_to_publishing_api).never

    login_as :writer

    post :republish_role, params: { role_slug: "an-existing-role" }
    assert_response :forbidden
  end

  view_test "GDS Admin users should be able to GET :find_document" do
    get :find_document

    assert_response :ok
  end

  test "Non-GDS Admin users should not be able to GET :find_document" do
    login_as :writer

    get :find_document
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :search_document with an existing document slug" do
    create(:document, slug: "an-existing-document")

    post :search_document, params: { document_slug: "an-existing-document" }

    assert_redirected_to admin_republishing_document_confirm_path("an-existing-document")
  end

  test "GDS Admin users should be redirected back to :find_document when trying to POST :search_document with a nonexistent document slug" do
    post :search_document, params: { document_slug: "not-an-existing-document" }

    assert_redirected_to admin_republishing_document_find_path
    assert_equal "Document with slug 'not-an-existing-document' not found", flash[:alert]
  end

  test "Non-GDS Admin users should not be able to POST :search_document" do
    create(:document, slug: "an-existing-document")

    login_as :writer

    post :search_document, params: { document_slug: "an-existing-document" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to GET :confirm_document with an existing document slug" do
    create(:document, slug: "an-existing-document")

    get :confirm_document, params: { document_slug: "an-existing-document" }
    assert_response :ok
  end

  test "GDS Admin users should see a 404 page when trying to GET :confirm_document with a nonexistent document slug" do
    get :confirm_document, params: { document_slug: "not-an-existing-document" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to GET :confirm_document" do
    create(:document, slug: "an-existing-document")

    login_as :writer

    get :confirm_document, params: { document_slug: "an-existing-document" }
    assert_response :forbidden
  end

  test "GDS Admin users should be able to POST :republish_document with an existing document slug, creating a RepublishingEvent for the current user" do
    document = create(:document, slug: "an-existing-document", content_id: "6de2fd22-4a87-49b7-be49-915f12dfe6fe")

    PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(document.id).once

    post :republish_document, params: { document_slug: "an-existing-document", reason: "this needs republishing" }

    newly_created_event = RepublishingEvent.last
    assert_equal newly_created_event.user, current_user
    assert_equal newly_created_event.reason, "this needs republishing"
    assert_equal newly_created_event.action, "Editions for the document with slug 'an-existing-document' have been republished"
    assert_equal newly_created_event.content_id, "6de2fd22-4a87-49b7-be49-915f12dfe6fe"

    assert_redirected_to admin_republishing_index_path
    assert_equal "Editions for the document with slug 'an-existing-document' have been republished", flash[:notice]
  end

  test "GDS Admin users should encounter an error on POST :republish_document without a `reason` and be sent back to the confirm page" do
    document = create(:document, slug: "an-existing-document")

    PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(document.id).never

    post :republish_document, params: { document_slug: "an-existing-document", reason: "" }

    assert_equal ["Reason can't be blank"], assigns(:republishing_event).errors.full_messages
    assert_template "confirm_document"
  end

  test "GDS Admin users should see a 404 page when trying to POST :republish_document with a nonexistent document slug" do
    PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).never

    post :republish_document, params: { document_slug: "not-an-existing-document" }
    assert_response :not_found
  end

  test "Non-GDS Admin users should not be able to POST :republish_document" do
    document = create(:document, slug: "an-existing-document")

    PublishingApiDocumentRepublishingWorker.any_instance.expects(:perform).with(document.id).never

    login_as :writer

    post :republish_document, params: { document_slug: "an-existing-document" }
    assert_response :forbidden
  end
end
