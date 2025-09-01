require "test_helper"

class Admin::EditionsHelperTest < ActionView::TestCase
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
    contact = create(:contact)
    assert_not warn_about_lack_of_contacts_in_body?(
      NewsArticle.new(
        news_article_type: NewsArticleType::PressRelease,
        body: "[Contact:#{contact.id}]",
      ),
    )
  end

  test "warn_about_lack_of_contacts_in_body? says yes if the edition is a press release and it has at no contacts embedded in the body" do
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
    edition = build(:worldwide_organisation)

    assert_equal "Worldwide organisation", edition_type(edition)
  end

  test "#edition_title_link_or_edition_title returns a link to the edition with its title as the text when the edition has a public URL" do
    edition = build(:published_edition, title: "It's my title!")
    public_url = "https://gov.uk/my-public-url"
    edition.stubs(:public_url).returns(public_url)

    assert_equal '<a class="govuk-link" href="https://gov.uk/my-public-url">It\'s my title!</a>', edition_title_link_or_edition_title(edition)
  end

  test "#edition_title_link_or_edition_title returns the edition title when the edition has no public URL" do
    edition = build(:published_edition, title: "It's my title!")
    edition.stubs(:public_url).returns(nil)

    assert_equal "It's my title!", edition_title_link_or_edition_title(edition)
  end

  test "#status_text returns just the state if it is anything other than unpublished or withdrawn" do
    edition = build(:published_edition)

    assert_equal "Published", status_text(edition)
  end

  test "#status_text returns both the state and time information if it is withdrawn" do
    edition = create(:withdrawn_edition)

    assert_equal "Withdrawn (less than a minute ago)", status_text(edition)
  end

  test "#status_text returns information about when the document was unpublished, and details about the unpublishing" do
    alternative_url = "https://gov.uk/foo"
    edition = create(:edition, :unpublished)

    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::CONSOLIDATED_ID
    edition.unpublishing.save!
    assert_equal "Unpublished (less than a minute ago) due to being consolidated into another page. User is redirected from<br><a href='https://www.test.gov.uk#{edition.base_path}'>https://www.test.gov.uk#{edition.base_path}</a><br>to<br><a href='#{alternative_url}'>#{alternative_url}</a>", status_text(edition)

    edition.unpublishing.unpublishing_reason_id = UnpublishingReason::PUBLISHED_IN_ERROR_ID
    edition.unpublishing.redirect = false
    edition.unpublishing.alternative_url = alternative_url
    edition.unpublishing.explanation = "the doc was published in error"
    edition.unpublishing.save!

    assert_equal "Unpublished (less than a minute ago) due to being published in error. User-facing reason: 'the doc was published in error'. Alternative URL displayed to user:<br><a href='#{alternative_url}'>#{alternative_url}</a>", status_text(edition)

    edition.unpublishing.created_at = 1.year.ago
    edition.unpublishing.redirect = true
    edition.unpublishing.save!
    assert_equal "Unpublished (about 1 year ago) due to being published in error. User is redirected from<br><a href='https://www.test.gov.uk#{edition.base_path}'>https://www.test.gov.uk#{edition.base_path}</a><br>to<br><a href='#{alternative_url}'>#{alternative_url}</a>", status_text(edition)
  end
end
