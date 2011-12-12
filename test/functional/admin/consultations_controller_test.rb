require 'test_helper'

class Admin::ConsultationsControllerTest < ActionController::TestCase

  setup do
    @user = login_as :policy_writer
  end

  test_controller_is_a Admin::BaseController

  test 'new displays consultation form' do
    get :new

    assert_select "form[action='#{admin_consultations_path}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
      assert_select "input[type='submit']"
    end
  end

  test 'creating creates a new consultation' do
    attributes = attributes_for(:consultation)

    post :create, document: attributes

    consultation = Consultation.last
    assert_equal attributes[:title], consultation.title
    assert_equal attributes[:body], consultation.body
    assert_equal attributes[:opening_on].to_date, consultation.opening_on
    assert_equal attributes[:closing_on].to_date, consultation.closing_on
  end

  test 'creating takes the writer to the consultation page' do
    post :create, document: attributes_for(:consultation)

    assert_redirected_to admin_consultation_path(Consultation.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'show displays consultation opening date' do
    consultation = create(:consultation, opening_on: Date.new(2011, 10, 10))
    get :show, id: consultation
    assert_select '.opening_on', text: 'Opened on October 10th, 2011'
  end

  test 'creating with invalid data should leave the writer in the consultation editor' do
    attributes = attributes_for(:consultation)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:consultation)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'show displays consultation closing date' do
    consultation = create(:consultation, opening_on: Date.new(2010, 01, 01), closing_on: Date.new(2011, 01, 01))
    get :show, id: consultation
    assert_select '.closing_on', text: 'Closed on January 1st, 2011'
  end

  test 'show displays related policies' do
    policy = create(:policy)
    consultation = create(:consultation, related_documents: [policy])
    get :show, id: consultation
    assert_select_object policy
  end

  test 'edit displays consultation form' do
    consultation = create(:consultation)

    get :edit, id: consultation

    assert_select "form[action='#{admin_consultation_path(consultation)}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name*='document[opening_on']", count: 3
      assert_select "select[name*='document[closing_on']", count: 3
      assert_select "input[type='submit']"
    end
  end

  test 'updating should save modified policy attributes' do
    consultation = create(:consultation)

    put :update, id: consultation, document: {
      title: "new-title",
      body: "new-body",
      opening_on: 1.day.ago,
      closing_on: 50.days.from_now
    }

    consultation.reload
    assert_equal "new-title", consultation.title
    assert_equal "new-body", consultation.body
    assert_equal 1.day.ago.to_date, consultation.opening_on
    assert_equal 50.days.from_now.to_date, consultation.closing_on
  end

  test 'updating a stale consultation should render edit page with conflicting consultation' do
    consultation = create(:draft_consultation, organisations: [build(:organisation)], ministerial_roles: [build(:ministerial_role)])
    lock_version = consultation.lock_version
    consultation.touch

    put :update, id: consultation, document: consultation.attributes.merge(
      lock_version: lock_version
    )

    assert_template 'edit'
    conflicting_consultation = consultation.reload
    assert_equal conflicting_consultation, assigns[:conflicting_document]
    assert_equal conflicting_consultation.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it}, flash[:alert]
  end

  should_allow_organisations_for :consultation
  should_allow_ministerial_roles_for :consultation

  should_allow_attachments_for :consultation
  should_display_attachments_for :consultation

  should_be_rejectable :consultation
  should_be_force_publishable :consultation
  should_be_able_to_delete_a_document :consultation

  should_link_to_public_version_when_published :consultation
  should_not_link_to_public_version_when_not_published :consultation

  should_prevent_modification_of_unmodifiable :consultation
end