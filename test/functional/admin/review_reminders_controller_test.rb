require "test_helper"

class Admin::ReviewRemindersControllerTest < ActionController::TestCase
  include Rails.application.routes.url_helpers
  include Admin::EditionRoutesHelper

  setup do
    login_as :gds_editor
    @document = create(:document)
    @edition = create(:published_edition, document: @document)
  end

  should_be_an_admin_controller

  test "GET to :new renders assigns the correct values and renders the correct template" do
    get :new, params: { document_id: @document }

    assert_equal assigns(:document), @document
    assert assigns(:review_reminder).is_a?(ReviewReminder)
    assert_template :new
  end

  test "POST to :create with valid data creates a new review reminder" do
    post :create,
         params: {
           document_id: @document,
           review_reminder: {
             "review_at(3i)": "7",
             "review_at(2i)": "7",
             "review_at(1i)": Time.zone.now.year + 1,
             email_address: "test@gmail.com",
           },
         }

    assert_equal "Review date created", flash[:notice]
    assert @document.reload.review_reminder.persisted?
    assert_redirected_to admin_edition_path(@edition)
  end

  test "POST to :create with invalid data it re-renders the new template" do
    post :create,
         params: {
           document_id: @document,
           review_reminder: {
             "review_at(3i)": "7",
             "review_at(2i)": "7",
             "review_at(1i)": Time.zone.now.year + 1,
             email_address: "",
           },
         }

    assert_equal assigns(:document), @document
    assert assigns(:review_reminder).is_a?(ReviewReminder)
    assert_template :new
  end

  test "GET to :edit renders assigns the correct values and renders the correct template" do
    review_reminder = create(:review_reminder, document: @document)

    get :edit, params: { document_id: @document, id: review_reminder }

    assert_equal assigns(:document), @document
    assert_equal assigns(:review_reminder), review_reminder
    assert_template :edit
  end

  test "PATCH to :update with valid data updates a new review reminder" do
    review_reminder = create(:review_reminder, document: @document, email_address: "test@googlemail.com")

    post :update,
         params: {
           document_id: @document,
           id: review_reminder.id,
           review_reminder: {
             "review_at(3i)": review_reminder.review_at.day,
             "review_at(2i)": review_reminder.review_at.month,
             "review_at(1i)": review_reminder.review_at.year,
             email_address: "test@gmail.com",
           },
         }

    assert_equal "Review date updated", flash[:notice]
    assert_equal review_reminder.reload.email_address, "test@gmail.com"
    assert_redirected_to admin_edition_path(@edition)
  end

  test "PATCH to :update with invalid data it re-renders the new template" do
    review_reminder = create(:review_reminder, document: @document, email_address: "test@googlemail.com")

    post :update,
         params: {
           document_id: @document,
           id: review_reminder.id,
           review_reminder: {
             "review_at(3i)": "7",
             "review_at(2i)": "7",
             "review_at(1i)": Time.zone.now.year + 1,
             email_address: "",
           },
         }

    assert_equal assigns(:document), @document
    assert_equal assigns(:review_reminder).email_address, ""
    assert_template :edit
  end
end
