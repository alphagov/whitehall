require "test_helper"

class PoliciesControllerTest < ActionController::TestCase
  test "should show inapplicable nations" do
    published_policy = create(:published_policy)
    northern_ireland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.northern_ireland, alternative_url: "http://northern-ireland.com/")
    scotland_inapplicability = published_policy.nation_inapplicabilities.create!(nation: Nation.scotland)

    get :show, id: published_policy.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This policy does not apply to Northern Ireland and Scotland."
      assert_select_object northern_ireland_inapplicability do
        assert_select "a[href='http://northern-ireland.com/']"
      end
      assert_select_object scotland_inapplicability, count: 0
    end
  end

  test "should explain that policy applies to the whole of the UK" do
    published_policy = create(:published_policy)

    get :show, id: published_policy.document_identity

    assert_select "#inapplicable_nations" do
      assert_select "p", "This policy applies to the whole of the UK."
    end
  end

  test "show displays related published publications" do
    related_publication = create(:published_publication, title: "Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_publication])

    get :show, id: published_policy.document_identity

    assert_select "#related-publications" do
      assert_select_object related_publication
    end
  end

  test "show excludes related unpublished publications" do
    related_publication = create(:draft_publication, title: "Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_publication])

    get :show, id: published_policy.document_identity

    assert_select "#related-publications", count: 0
  end

  test "show displays related published consultations" do
    related_consultation = create(:published_consultation, title: "Consultation on Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_consultation])

    get :show, id: published_policy.document_identity

    assert_select "#related-consultations" do
      assert_select_object related_consultation
    end
  end

  test "show excludes related unpublished consultations" do
    related_consultation = create(:draft_consultation, title: "Consultation on Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_consultation])

    get :show, id: published_policy.document_identity

    assert_select "#related-consultations", count: 0
  end

  test "show displays related news articles" do
    related_news_article = create(:published_news_article, title: "News about Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_news_article])

    get :show, id: published_policy.document_identity

    assert_select "#related-news-articles" do
      assert_select_object related_news_article
    end
  end

  test "show excludes related unpublished news articles" do
    related_news_article = create(:draft_news_article, title: "News about Voting Patterns")
    published_policy = create(:published_policy, documents_related_with: [related_news_article])

    get :show, id: published_policy.document_identity

    assert_select "#related-news-articles", count: 0
  end
end