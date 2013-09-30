require "test_helper"

class Admin::EditionsHelperTest < ActionView::TestCase
  def govspeak_embedded_contacts(*args)
    []
  end

  test 'warn_about_lack_of_contacts_in_body? says no if the edition is not a news article' do
    (Edition.descendants - [NewsArticle] - NewsArticle.descendants).each do |not_a_news_article|
      refute warn_about_lack_of_contacts_in_body?(not_a_news_article.new)
    end
  end

  test 'warn_about_lack_of_contacts_in_body? says no if the edition is a news article, but is not a press release' do
    (NewsArticleType.all - [NewsArticleType::PressRelease]).each do |not_a_press_release|
      refute warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: not_a_press_release))
    end
  end

  test 'warn_about_lack_of_contacts_in_body? says no if the edition is a press release and it has at least one contact embedded in the body' do
    stubs(:govspeak_embedded_contacts).returns([build(:contact)])
    refute warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test 'warn_about_lack_of_contacts_in_body? says yes if the edition is a press release and it has at no contacts embedded in the body' do
    stubs(:govspeak_embedded_contacts).returns([])
    assert warn_about_lack_of_contacts_in_body?(NewsArticle.new(news_article_type: NewsArticleType::PressRelease))
  end

  test 'default_edition_tabs includes document collection tab for a persisted document collection' do
    document_collection = build(:document_collection)
    refute_includes default_edition_tabs(document_collection).keys, "Collection documents"
    document_collection = create(:document_collection)
    assert_includes default_edition_tabs(document_collection).keys, "Collection documents"
  end
end
