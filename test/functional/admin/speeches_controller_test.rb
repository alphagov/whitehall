require 'test_helper'

class Admin::SpeechesControllerTest < ActionController::TestCase
  setup do
    @user = login_as "George"
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test 'creating should create a new speech' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    first_org = create(:organisation)
    second_org = create(:organisation)
    attributes = attributes_for(:speech)

    post :create, document: attributes.merge(
      topic_ids: [first_topic.id, second_topic.id],
      organisation_ids: [first_org.id, second_org.id]
    )

    created_speech = Speech.last
    assert_equal attributes[:title], created_speech.title
    assert_equal attributes[:body], created_speech.body
    assert_equal [first_topic, second_topic], created_speech.topics
    assert_equal [first_org, second_org], created_speech.organisations
  end

  test 'creating should take the writer to the speech page' do
    post :create, document: attributes_for(:speech)

    assert_redirected_to admin_speech_path(Speech.last)
    assert_equal 'The document has been saved', flash[:notice]
  end

  test 'creating with invalid data should leave the writer in the speech editor' do
    attributes = attributes_for(:speech)
    post :create, document: attributes.merge(title: '')

    assert_equal attributes[:body], assigns(:document).body, "the valid data should not have been lost"
    assert_template "documents/new"
  end

  test 'creating with invalid data should set an alert in the flash' do
    attributes = attributes_for(:speech)
    post :create, document: attributes.merge(title: '')

    assert_equal 'There are some problems with the document', flash.now[:alert]
  end

  test 'updating should save modified document attributes' do
    first_topic = create(:topic)
    second_topic = create(:topic)
    speech = create(:speech, topics: [first_topic])

    put :update, id: speech.id, document: { title: "new-title", body: "new-body", topic_ids: [second_topic.id] }

    saved_speech = speech.reload
    assert_equal "new-title", saved_speech.title
    assert_equal "new-body", saved_speech.body
    assert_equal [second_topic], saved_speech.topics
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
end
