require 'test_helper'

class Admin::SpeechesControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test "new displays speech form" do
    get :new

    assert_select "form[action='#{admin_speeches_path}']" do
      assert_select "input[name='document[title]'][type='text']"
      assert_select "textarea[name='document[body]']"
      assert_select "select[name='document[role_appointment_id]']"
      assert_select "select[name*='document[delivered_on']", count: 3
      assert_select "input[name='document[location]'][type='text']"
      assert_select "input[type='submit']"
    end
  end

  test 'creating should create a new speech' do
    role_appointment = create(:role_appointment)
    attributes = attributes_for(:speech).merge(
      role_appointment_id: role_appointment.id
    )

    post :create, document: attributes

    assert speech = Speech.last
    assert_equal attributes[:title], speech.title
    assert_equal attributes[:body], speech.body
    assert_equal role_appointment, speech.role_appointment
    assert_equal attributes[:delivered_on], speech.delivered_on
    assert_equal attributes[:location], speech.location
  end

  test 'creating should take the writer to the speech page' do
    role_appointment = create(:role_appointment)
    attributes = attributes_for(:speech).merge(
      role_appointment_id: role_appointment.id
    )

    post :create, document: attributes

    assert_redirected_to admin_speech_path(Speech.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the speech editor' do
    role_appointment = create(:role_appointment)
    attributes = attributes_for(:speech).merge(
      role_appointment_id: role_appointment.id
    )

    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    role_appointment = create(:role_appointment)
    attributes = attributes_for(:speech).merge(
      role_appointment_id: role_appointment.id
    )

    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating should save modified document attributes' do
    speech = create(:speech)
    new_role_appointment = create(:role_appointment)
    new_delivered_on = speech.delivered_on + 1

    put :update, id: speech.id, document: {
      title: "new-title",
      body: "new-body",
      role_appointment_id: new_role_appointment.id,
      delivered_on: new_delivered_on,
      location: "new-location"
    }

    speech = speech.reload
    assert_equal "new-title", speech.title
    assert_equal "new-body", speech.body
    assert_equal new_role_appointment, speech.role_appointment
    assert_equal new_delivered_on, speech.delivered_on
    assert_equal "new-location", speech.location
  end

  test 'updating should take the writer to the speech page' do
    speech = create(:speech)
    put :update, id: speech.id, document: {title: 'new-title', body: 'new-body'}

    assert_redirected_to admin_speech_path(speech)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'updating with invalid data should not save the speech' do
    attributes = attributes_for(:speech)
    speech = create(:speech, attributes)
    put :update, id: speech.id, document: attributes.merge(title: '')

    assert_equal attributes[:title], speech.reload.title
    assert_template "documents/edit"
    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating a stale speech should render edit page with conflicting speech' do
    speech = create(:draft_speech)
    lock_version = speech.lock_version
    speech.update_attributes!(title: "new title")

    put :update, id: speech, document: speech.attributes.merge(lock_version: lock_version)

    assert_template 'edit'
    conflicting_speech = speech.reload
    assert_equal conflicting_speech, assigns[:conflicting_document]
    assert_equal conflicting_speech.lock_version, assigns[:document].lock_version
    assert_equal %{This document has been saved since you opened it}, flash[:alert]
  end

  test "cancelling a new speech takes the user to the list of drafts" do
    get :new
    assert_select "a[href=#{admin_documents_path}]", text: /cancel/i, count: 1
  end

  test "cancelling an existing speech takes the user to that speech" do
    draft_speech = create(:draft_speech)
    get :edit, id: draft_speech
    assert_select "a[href=#{admin_speech_path(draft_speech)}]", text: /cancel/i, count: 1
  end

  test 'updating a submitted speech with bad data should show errors' do
    attributes = attributes_for(:submitted_speech)
    submitted_speech = create(:submitted_speech, attributes)
    put :update, id: submitted_speech, document: attributes.merge(title: '')

    assert_template 'edit'
  end

  test "should render the content using govspeak markup" do
    draft_speech = create(:draft_speech, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: draft_speech

    assert_select ".body", text: "body-in-html"
  end

  test "should display who delivered the speech, and when & where it was delivered" do
    home_office = create(:organisation, name: "Home Office")
    home_secretary = create(:ministerial_role, name: "Secretary of State", organisations: [home_office])
    theresa_may = create(:person, name: "Theresa May")
    theresa_may_appointment = create(:role_appointment, role: home_secretary, person: theresa_may)
    draft_speech = create(:draft_speech, role_appointment: theresa_may_appointment, delivered_on: Date.parse("2011-06-01"), location: "The Guidhall")

    get :show, id: draft_speech

    assert_select ".delivery .ministerial_role", "Theresa May (Secretary of State, Home Office)"
    assert_select ".delivery .date", "June 1st, 2011"
    assert_select ".delivery .location", "The Guidhall"
  end

end