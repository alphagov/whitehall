require 'test_helper'

class Admin::DocumentsControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  test 'should distinguish between document types when viewing the list of draft documents' do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :draft

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    assert_select_object(publication) { assert_select ".type", text: "Publication" }
  end

  test "should order by most recently updated" do
    policy = create(:draft_policy, updated_at: 3.days.ago)
    newer_policy = create(:draft_policy, updated_at: 1.minute.ago)
    get :draft

    assert_equal [newer_policy, policy], assigns(:documents)
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
    published_document.expects(:create_draft).with(current_user).returns(draft_document)
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
    assert_equal "There is already an active draft edition for this document", flash[:alert]
  end

  test "failing to revise an document should redirect to the existing submitted document" do
    published_document = create(:published_policy)
    existing_submitted = create(:submitted_policy, document_identity: published_document.document_identity)

    post :revise, id: published_document

    assert_redirected_to edit_admin_policy_path(existing_submitted)
    assert_equal "There is already an active submitted edition for this document", flash[:alert]
  end

  test "failing to revise an document should redirect to the existing rejected document" do
    published_document = create(:published_publication)
    existing_rejected = create(:rejected_publication, document_identity: published_document.document_identity)

    post :revise, id: published_document

    assert_redirected_to edit_admin_publication_path(existing_rejected)
    assert_equal "There is already an active rejected edition for this document", flash[:alert]
  end

  test "should be able to filter by policies when viewing list of documents" do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :draft, filter: 'policy'

    assert_select_object(policy) { assert_select ".type", text: "Policy" }
    refute_select ".type", text: "Publication"
  end

  test "should be able to filter by publications when viewing list of documents" do
    policy = create(:draft_policy)
    publication = create(:draft_publication)
    get :draft, filter: 'publication'

    assert_select_object(publication) { assert_select ".type", text: "Publication" }
    refute_select ".type", text: "Policy"
  end

  test "should be able to filter by speeches when viewing list of documents" do
    policy = create(:draft_policy)
    speech = create(:speech)
    get :draft, filter: 'speech'

    assert_select_object(speech) { assert_select ".type", text: "Speech" }
    refute_select ".type", text: "Policy"
  end

  test "should be able to filter by news articles when viewing list of documents" do
    policy = create(:draft_policy)
    news = create(:news_article)
    get :draft, filter: 'news_article'

    assert_select_object(news) { assert_select ".type", text: "News Article" }
    refute_select ".type", text: "Policy"
  end

  test "should be able to filter by consultations when viewing list of documents" do
    policy = create(:draft_policy)
    consultation = create(:consultation)
    get :draft, filter: 'consultation'

    assert_select_object(consultation) { assert_select ".type", text: "Consultation" }
    refute_select ".type", text: "Policy"
  end

  test "should be able to filter by consultation responses when viewing list of documents" do
    policy = create(:draft_policy)
    consultation_response = create(:consultation_response)
    get :draft, filter: 'consultation_response'

    assert_select_object(consultation_response) { assert_select ".type", text: "Consultation Response" }
    refute_select ".type", text: "Policy"
  end

  test "should be able to show only documents authored by user when viewing list of documents" do
    user = create(:policy_writer)
    authored_policy = create(:draft_policy, creator: user)
    other_policy = create(:draft_policy)

    get :draft, author: user

    assert_select_object authored_policy
    refute_select_object other_policy
  end

  test "should be able to show only documents related to an organisation" do
    organisation = create(:organisation)
    user = create(:policy_writer, organisation: organisation)

    policy_in_organisation = create(:draft_policy, organisations: [organisation])
    other_policy = create(:draft_policy, organisations: [create(:organisation)])

    get :draft, organisation: organisation

    assert_select_object policy_in_organisation
    refute_select_object other_policy
  end

  test "should remember standard filter options" do
    get :draft, filter: 'consultation'
    assert_equal 'consultation', session[:document_filters][:filter]
  end

  test "should remember author filter options" do
    get :draft, author: current_user
    assert_equal current_user.to_param, session[:document_filters][:author]
  end

  test "should remember organisation filter options" do
    organisation = create(:organisation)
    get :draft, organisation: organisation
    assert_equal organisation.to_param, session[:document_filters][:organisation]
  end

  test "should remember state filter options" do
    get :draft
    assert_equal 'draft', session[:document_filters][:action]
  end

  test "index should redirect to remembered filtered options if available" do
    organisation = create(:organisation)
    session[:document_filters] = { action: :submitted, author: current_user.to_param, organisation: organisation.to_param }
    get :index
    assert_redirected_to submitted_admin_documents_path(author: current_user, organisation: organisation)
  end

  test "index should redirect to submitted in my department if logged an editor has no remembered filters" do
    organisation = create(:organisation)
    editor = login_as create(:departmental_editor, organisation: organisation)
    get :index
    assert_redirected_to submitted_admin_documents_path(organisation: organisation)
  end

  test "index should redirect to drafts I have written if a writer has no remembered filters" do
    writer = login_as create(:policy_writer)
    get :index
    assert_redirected_to draft_admin_documents_path(author: writer)
  end

  test "index should redirect to drafts if filtered options don't form a route" do
    session[:document_filters] = { action: :unknown }
    get :index
    assert_redirected_to draft_admin_documents_path
  end

  [:publication, :consultation].each do |document_type|
    test "should display a form for featuring an unfeatured #{document_type} without a featuring image" do
      document = create("published_#{document_type}")
      get :published, filter: document_type
      expected_url = send("admin_document_featuring_path", document)
      assert_select ".featured form.feature[action=#{expected_url}]" do
        refute_select "input[name=_method]"
        refute_select "input[name='document[featuring_image]']"
        assert_select "input[type=submit][value='Feature']"
      end
    end

    test "should display a form for unfeaturing a featured #{document_type} without a featuring image" do
      document = create("featured_#{document_type}")
      get :published, filter: document_type
      expected_url = send("admin_document_featuring_path", document)
      assert_select ".featured form.unfeature[action=#{expected_url}]" do
        assert_select "input[name=_method][value=delete]"
        refute_select "input[name='document[featuring_image]']"
      end
    end

    test "should not show featuring image on a featured #{document_type} because they do not allow a featuring image" do
      document = create("featured_#{document_type}")
      get :published, filter: document_type
      assert_select ".featured" do
        refute_select "img"
      end
    end
  end

  test "should display a form for featuring an unfeatured news article with a featuring image" do
    news_article = create(:published_news_article)
    get :published, filter: :news_article
    expected_url = send("admin_document_featuring_path", news_article)
    assert_select ".featured form.feature[action=#{expected_url}]" do
      refute_select "input[name=_method]"
      assert_select "input[name='document[featuring_image]'][type=file]"
      assert_select "input[type=submit][value='Feature']"
    end
  end

  test "should display a form for unfeaturing a featured news article with a featuring image" do
    news_article = create(:featured_news_article)
    get :published, filter: :news_article
    expected_url = send("admin_document_featuring_path", news_article)
    assert_select ".featured form.unfeature[action=#{expected_url}]" do
      assert_select "input[name=_method][value=delete]"
      assert_select "input[type=submit][value='No longer feature']"
    end
  end

  test "should display a form for updating featuring image on a news article" do
    news_article = create(:featured_news_article)
    get :published, filter: :news_article
    expected_url = send("admin_document_featuring_path", news_article)
    assert_select ".featured form.update_image[action=#{expected_url}]" do
      assert_select "input[name=_method][value=put]"
      assert_select "input[name='document[featuring_image]'][type=file]"
      assert_select "input[type=submit][value='Update image']"
    end
  end

  test "should show featuring image on featured news article if it has one" do
    featuring_image = fixture_file_upload('portas-review.jpg')
    news_article = create(:featured_news_article, featuring_image: featuring_image)
    get :published, filter: :news_article
    assert_select ".featured" do
      assert_select "img[src$='portas-review.jpg']"
    end
  end

  test "should not show featuring image on featured news article if it does not have one" do
    news_article = create(:featured_news_article, featuring_image: nil)
    get :published, filter: :news_article
    assert_select ".featured" do
      refute_select "img[src$='portas-review.jpg']"
    end
  end

  test "should not display the featured column on the 'all document' page" do
    policy = create(:draft_policy)
    refute policy.featurable?
    get :draft
    refute_select "th", text: "Featured"
    refute_select "td.featured"
  end

  test "should not display the featured column on a filtered document page where that document isn't featureable" do
    policy = create(:draft_policy)
    refute policy.featurable?
    get :draft, filter: "policy"
    refute_select "th", text: "Featured"
    refute_select "td.featured"
  end

  test "should not show published documents as force published" do
    policy = create(:published_policy)
    get :published, filter: :policy

    assert_select_object(policy)
    refute_select "tr.force_published"
  end

  test "should show force published documents as force published" do
    policy = create(:published_policy, force_published: true)
    get :published, filter: :policy

    assert_select_object(policy)
    assert_select "tr.force_published"
  end
end
