require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  should_render_a_list_of :policies

  test "should show inapplicable nations" do
    published_policy = create(:published_policy)
    northern_ireland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_policy.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      refute_select_object scotland_inapplicability
    end
  end

  test "should explain that policy applies to the whole of the UK" do
    published_policy = create(:published_policy)

    get :show, id: published_policy.document_identity

    assert_select inapplicable_nations_selector do
      assert_select "p", "This policy applies to the whole of the UK."
    end
  end

  test "show displays recently changed documents relating to the policy" do
    publication = create(:published_publication)
    consultation = create(:published_consultation)
    news_article = create(:published_news_article)
    speech = create(:published_speech)
    policy = create(:published_policy,
      documents_related_with: [publication, consultation, news_article, speech]
    )

    get :show, id: policy.document_identity

    assert_select "#recently-changed" do
      assert_select_object publication
      assert_select_object consultation
      assert_select_object news_article
      assert_select_object speech
    end
  end

  test "show displays metadata about the recently changed documents" do
    published_at = Time.zone.now
    speech = create(:published_speech_transcript, published_at: published_at)
    policy = create(:published_policy,
      documents_related_with: [speech]
    )

    get :show, id: policy.document_identity

    assert_select "#recently-changed" do
      assert_select_object speech do
        assert_select ".metadata .document_type", text: "Speech"
        assert_select ".metadata .published_at[title='#{published_at.iso8601}']"
      end
    end
  end

  test "show orders recently changed documents relating to the policy most recent first" do
    publication = create(:published_publication, published_at: 4.weeks.ago)
    consultation = create(:published_consultation, published_at: 1.weeks.ago)
    news_article = create(:published_news_article, published_at: 3.weeks.ago)
    speech = create(:published_speech, published_at: 2.weeks.ago)
    policy = create(:published_policy,
      documents_related_with: [publication, consultation, news_article, speech]
    )

    get :show, id: policy.document_identity

    assert_equal [consultation, speech, news_article, publication], assigns[:recently_changed_documents]
  end

  test "show displays related published publications" do
    related_publication = create(:published_publication, title: "Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_publication])

    get :show, id: published_policy.document_identity

    assert_select related_publications_selector do
      assert_select_object related_publication
    end
  end

  test "show excludes related unpublished publications" do
    related_publication = create(:draft_publication, title: "Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_publication])

    get :show, id: published_policy.document_identity

    refute_select related_publications_selector
  end

  test "show displays related published consultations" do
    related_consultation = create(:published_consultation, title: "Consultation on Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_consultation])

    get :show, id: published_policy.document_identity

    assert_select related_consultations_selector do
      assert_select_object related_consultation
    end
  end

  test "show excludes related unpublished consultations" do
    related_consultation = create(:draft_consultation, title: "Consultation on Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_consultation])

    get :show, id: published_policy.document_identity

    refute_select related_consultations_selector
  end

  test "show displays related news articles" do
    related_news_article = create(:published_news_article, title: "News about Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_news_article])

    get :show, id: published_policy.document_identity

    assert_select related_news_articles_selector do
      assert_select_object related_news_article
    end
  end

  test "show excludes related unpublished news articles" do
    related_news_article = create(:draft_news_article, title: "News about Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_news_article])

    get :show, id: published_policy.document_identity

    refute_select related_news_articles_selector
  end

  test "show lists supporting documents when there are some" do
    published_document = create(:published_policy)
    first_supporting_page = create(:supporting_document, document: published_document)
    second_supporting_page = create(:supporting_document, document: published_document)

    get :show, id: published_document.document_identity

    assert_select ".policy_view nav" do
      assert_select "a[href='#{policy_supporting_document_path(published_document.document_identity, first_supporting_page)}']", text: first_supporting_page.title
      assert_select "a[href='#{policy_supporting_document_path(published_document.document_identity, second_supporting_page)}']", text: second_supporting_page.title
    end
  end

  test "doesn't show supporting documents list when empty" do
    published_document = create(:published_policy)

    get :show, id: published_document.document_identity

    refute_select supporting_pages_selector
  end

  test "should render the content using govspeak markup" do
    published_policy = create(:published_policy, body: "body-in-govspeak")
    Govspeak::Document.stubs(:to_html).with("body-in-govspeak").returns("body-in-html")

    get :show, id: published_policy.document_identity

    assert_select ".body", text: "body-in-html"
  end

  test "should render 404 if the document doesn't have a published document" do
    document_identity = create(:document_identity)
    get :show, id: document_identity

    assert_response :not_found
  end

  test "should display the published document" do
    document_identity = create(:document_identity)
    create(:archived_policy)
    published_document = create(:published_policy, document_identity: document_identity)
    create(:draft_policy, document_identity: document_identity)
    get :show, id: document_identity

    assert_response :success
    assert_equal published_document, assigns[:document]
  end

  test "should link to policy areas from within the metadata navigation" do
    first_policy_area = create(:policy_area)
    second_policy_area = create(:policy_area)
    document = create(:published_policy, policy_areas: [first_policy_area, second_policy_area])

    get :show, id: document.document_identity

    assert_select "#{metadata_nav_selector} a.policy_area", text: first_policy_area.name
    assert_select "#{metadata_nav_selector} a.policy_area", text: second_policy_area.name
  end

  test "should link to organisations from within the metadata navigation" do
    first_org = create(:organisation)
    second_org = create(:organisation)
    document = create(:published_policy, organisations: [first_org, second_org])

    get :show, id: document.document_identity

    assert_select "#{metadata_nav_selector} a.organisation", text: first_org.name
    assert_select "#{metadata_nav_selector} a.organisation", text: second_org.name
  end

  test "should link to ministers from within the metadata navigation" do
    role = create(:ministerial_role)
    appointment = create(:role_appointment, person: create(:person, name: "minister-name"), role: role)
    document = create(:published_policy, ministerial_roles: [appointment.role])

    get :show, id: document.document_identity

    assert_select "#{metadata_nav_selector} a.minister", text: "minister-name"
  end
end