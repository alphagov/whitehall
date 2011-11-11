require "test_helper"

class SupportingDocumentsControllerTest < ActionController::TestCase
  test "index links to supporting documents" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, title: "supporting-document-title", document: policy)
    get :index, policy_id: policy.document_identity
    path = policy_supporting_document_path(policy.document_identity, supporting_document)
    assert_select "#supporting_documents" do
      assert_select_object supporting_document do
        assert_select "a[href=#{path}]"
        assert_select ".title", text: "supporting-document-title"
      end
    end
  end

  test "index only shows supporting documents for the parent policy" do
    policy = create(:published_policy)
    other_supporting_document = create(:supporting_document)
    get :index, policy_id: policy.document_identity
    assert_select_object other_supporting_document, false
  end

  test "index doesn't display an empty list if there aren't any supporting documents" do
    policy = create(:published_policy)
    get :index, policy_id: policy.document_identity
    assert_select "#supporting_documents ul", count: 0
  end

  test "shows title and link to parent document" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select ".title", text: supporting_document.title
    assert_select "a[href='#{policy_path(policy.document_identity)}']", text: "Back to '#{policy.title}'"
  end

  test "shows the body using govspeak markup" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select ".body", text: "body-in-html"
  end

  test "doesn't show supporting document if parent isn't published" do
    policy = create(:draft_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_response :not_found
  end

  test "should show inapplicable nations" do
    policy = create(:published_policy)
    northern_ireland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = policy.nation_inapplicabilities.create!(nation: Nation.scotland)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#inapplicable_nations" do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      assert_select_object scotland_inapplicability, count: 0
    end
  end

  test "should explain that policy applies to the whole of the UK" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#inapplicable_nations" do
      assert_select "p", "This policy applies to the whole of the UK."
    end
  end

  test "show displays related published publications" do
    related_publication = create(:published_publication, title: "Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_publication])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#related-publications" do
      assert_select_object related_publication
    end
  end

  test "show excludes related unpublished publications" do
    related_publication = create(:draft_publication, title: "Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_publication])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#related-publications", count: 0
  end

  test "show displays related published consultations" do
    related_consultation = create(:published_consultation, title: "Consultation on Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_consultation])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#related-consultations" do
      assert_select_object related_consultation
    end
  end

  test "show excludes related unpublished consultations" do
    related_consultation = create(:draft_consultation, title: "Consultation on Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_consultation])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#related-consultations", count: 0
  end

  test "show displays related news articles" do
    related_news_article = create(:published_news_article, title: "News about Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_news_article])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#related-news-articles" do
      assert_select_object related_news_article
    end
  end

  test "show excludes related unpublished news articles" do
    related_news_article = create(:draft_news_article, title: "News about Voting Patterns")
    policy = create(:published_policy, documents_related_with: [related_news_article])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#related-news-articles", count: 0
  end

  test "show lists supporting documents when there are some" do
    policy = create(:published_policy)
    first_supporting_document = create(:supporting_document, document: policy)
    second_supporting_document = create(:supporting_document, document: policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select "#supporting_documents" do
      assert_select_object(first_supporting_document) do
        assert_select "a[href='#{policy_supporting_document_path(policy.document_identity, first_supporting_document)}']", text: first_supporting_document.title
      end
      assert_select_object(second_supporting_document) do
        assert_select "a[href='#{policy_supporting_document_path(policy.document_identity, second_supporting_document)}']", text: second_supporting_document.title
      end
    end
  end

  test "should display the published document" do
    document_identity = create(:document_identity)
    create(:archived_policy, document_identity: document_identity)
    policy = create(:published_policy, document_identity: document_identity)
    create(:draft_policy, document_identity: document_identity)
    supporting_document = create(:supporting_document, document: policy)
    get :show, policy_id: document_identity, id: supporting_document

    assert_response :success
    assert_equal policy, assigns[:policy]
  end

  test "should display topics" do
    first_topic = create(:topic)
    second_topic = create(:topic)
    policy = create(:published_policy, topics: [first_topic, second_topic])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select topics_selector, count: 1
    assert_select ".topic", text: first_topic.name
    assert_select ".topic", text: second_topic.name
  end

  test "should not display the topics section if there aren't any" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select topics_selector, count: 0
  end

  test "should display organisations" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    policy = create(:published_policy, organisations: [first_org, second_org])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select organisations_selector, count: 1
    assert_select ".organisation", text: first_org.name
    assert_select ".organisation", text: second_org.name
  end

  test "should not display the organisations section if there aren't any" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select organisations_selector, count: 0
  end

  test "should display the minister section" do
    policy = create(:published_policy, ministerial_roles: [build(:ministerial_role)])
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select ministers_responsible_selector, count: 1
  end

  test "should not display an empty ministers section" do
    policy = create(:published_policy)
    supporting_document = create(:supporting_document, document: policy)

    get :show, policy_id: policy.document_identity, id: supporting_document

    assert_select ministers_responsible_selector, count: 0
  end

  def organisations_selector
    "#organisations"
  end

  def topics_selector
    "#topics"
  end

  def ministers_responsible_selector
    "#ministers_responsible"
  end
end
