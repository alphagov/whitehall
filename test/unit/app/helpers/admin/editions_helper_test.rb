require "test_helper"

class Admin::EditionsHelperTest < ActionView::TestCase
  def govspeak_embedded_contacts(*_args)
    []
  end

  def current_user
    @user
  end

  setup do
    @user = create(:user)
  end

  test "warn_about_lack_of_contacts_in_body? says no if the edition is not a news article" do
    (Edition.descendants - [NewsArticle] - NewsArticle.descendants).each do |not_a_news_article|
      assert_not warn_about_lack_of_contacts_in_body?(not_a_news_article.new)
    end
  end

  test "warn_about_lack_of_contacts_in_body? says no if the edition is a news article, but is not a press release" do
    (NewsArticleType.all - [NewsArticleType::PressRelease]).each do |not_a_press_release|
      assert_not warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: not_a_press_release))
    end
  end

  test "warn_about_lack_of_contacts_in_body? says no if the edition is a press release and it has at least one contact embedded in the body" do
    stubs(:govspeak_embedded_contacts).returns([build(:contact)])
    assert_not warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test "warn_about_lack_of_contacts_in_body? says yes if the edition is a press release and it has at no contacts embedded in the body" do
    stubs(:govspeak_embedded_contacts).returns([])
    assert warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test "#admin_author_filter_options excludes disabled users" do
    current_user, _another_user = *create_list(:user, 2)
    disabled_user = create(:disabled_user)

    assert_not_includes admin_author_filter_options(current_user), disabled_user
  end

  def one_hundred_thousand_words
    " There are ten words contained in this sentence there are" * 10_000
  end

  test "#show_link_check_report does not execute LinkCheckerApiService#has_links? when the edition is novel length" do
    edition = stub(body: one_hundred_thousand_words)
    LinkCheckerApiService.expects(:has_links?).never
    show_link_check_report?(edition)
  end

  test "#reset_search_fields_query_string_params returns the correct params when the user has no organisation" do
    user = build_stubbed(:user)
    expected_result = "#{admin_editions_path}?state=active#anchor"

    assert_equal expected_result, reset_search_fields_query_string_params(user, admin_editions_path, "#anchor")
  end

  test "#reset_search_fields_query_string_params returns the correct params when the user belongs to an organisation and the filter action isn't the admin_editions_path" do
    organisation = build_stubbed(:organisation)
    user = build_stubbed(:user, organisation:)
    expected_result = "/any-other-path?state=active#anchor"

    assert_equal expected_result, reset_search_fields_query_string_params(user, "/any-other-path", "#anchor")
  end

  test "#reset_search_fields_query_string_params returns the correct params when the user belongs to an organisation and the filter action is the admin_editions_path" do
    organisation = build_stubbed(:organisation)
    user = build_stubbed(:user, organisation:)
    expected_result = "#{admin_editions_path}?state=active&organisation=#{organisation.id}#anchor"

    assert_equal expected_result, reset_search_fields_query_string_params(user, admin_editions_path, "#anchor")
  end

  test "#edition_type returns a concatenated string where an edition has a parent type" do
    edition = build(:news_article)

    assert_equal "News article: Press release", edition_type(edition)
  end

  test "#edition_type returns a single string where an edition does not have a parent type" do
    edition = build(:editionable_worldwide_organisation)

    assert_equal "Worldwide organisation", edition_type(edition)
  end
end
