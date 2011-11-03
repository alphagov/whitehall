require 'test_helper'

class Admin::DocumentsControllerTest < ActionController::TestCase
  setup do
    @user = login_as :policy_writer
  end

  test 'is an admin controller' do
    assert @controller.is_a?(Admin::BaseController), "the controller should have the behaviour of an Admin::BaseController"
  end

  test 'should distinguish between document types when viewing the list of draft documents' do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :index

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'should distinguish between document types when viewing the list of submitted documents' do
    policy = create(:submitted_policy)
    publication = create(:submitted_publication)
    get :submitted

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'should distinguish between document types when viewing the list of published documents' do
    policy = create(:published_policy)
    publication = create(:published_publication)
    get :published

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test 'viewing the list of submitted policies should not show draft policies' do
    draft_document = create(:draft_policy)
    get :submitted

    refute assigns(:documents).include?(draft_document)
  end

  test 'viewing the list of published policies should only show published policies' do
    published_documents = [create(:published_policy)]
    get :published

    assert_equal published_documents, assigns(:documents)
  end

  test 'submitting should set submitted on the document' do
    draft_document = create(:draft_policy)
    post :submit, id: draft_document

    assert draft_document.reload.submitted?
  end

  test 'submitting should redirect back to show page' do
    draft_document = create(:draft_policy)
    post :submit, id: draft_document

    assert_redirected_to admin_policy_path(draft_document)
    assert_equal "Your document has been submitted for review by a second pair of eyes", flash[:notice]
  end

  test "revising the published document should create a new draft document" do
    published_document = create(:published_policy)
    Document.stubs(:find).returns(published_document)
    draft_document = create(:draft_policy)
    published_document.expects(:create_draft).with(@user).returns(draft_document)
    draft_document.expects(:valid?).returns(true)

    post :revise, id: published_document
  end

  test "revising a published document redirects to edit for the new draft" do
    published_document = create(:published_policy)

    post :revise, id: published_document

    draft_document = Document.last
    assert_redirected_to edit_admin_policy_path(draft_document.reload)
  end

  test "failing to revise an document should redirect to the existing draft" do
    published_document = create(:published_policy)
    existing_draft = create(:draft_policy, document_identity: published_document.document_identity)

    post :revise, id: published_document

    assert_redirected_to edit_admin_policy_path(existing_draft)
    assert_equal "There is already an active draft for this document", flash[:alert]
  end

  test "should be able to filter by policies when viewing list of documents" do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :index, filter: 'policy'

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select ".type", text: "Publication", count: 0
  end

  test "should be able to filter by publications when viewing list of documents" do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :index, filter: 'publication'

    assert_select_object(publication) { assert_select ".type", text: "Publication" }
    assert_select ".type", text: "Policy", count: 0
  end

  test "should be able to filter by speeches when viewing list of documents" do
    policy = create(:draft_policy)
    speech_types = [
      :speech_transcript,
      :speech_draft_text,
      :speech_speaking_notes,
      :speech_written_statement,
      :speech_oral_statement
    ]
    instances_of_each_speech_type = speech_types.map {|t| create(t) }

    get :index, filter: 'speech'

    instances_of_each_speech_type.each do |speech|
      assert_select_object(speech) { assert_select ".type", text: speech.type.titleize }
    end

    assert_select ".type", text: "Policy", count: 0
  end

  test "should be able to filter by news articles when viewing list of documents" do
    policy = create(:draft_policy)
    news = create(:news_article)
    get :index, filter: 'news_article'

    assert_select_object(news) { assert_select ".type", text: "News Article" }
    assert_select ".type", text: "Policy", count: 0
  end

  test "should be able to filter by consultations when viewing list of documents" do
    policy = create(:draft_policy)
    consultation = create(:consultation)
    get :index, filter: 'consultation'

    assert_select_object(consultation) { assert_select ".type", text: "Consultation" }
    assert_select ".type", text: "Policy", count: 0
  end
end
