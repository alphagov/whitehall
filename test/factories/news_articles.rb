FactoryGirl.define do
  factory :news_article do
    author
    title "news-title"
    body  "news-body"
  end

  factory :draft_news_article, parent: :news_article do
    state "draft"
  end

  factory :submitted_news_article, parent: :news_article do
    state "submitted"
  end

  factory :rejected_news_article, parent: :news_article do
    state "rejected"
  end

  factory :published_news_article, parent: :news_article do
    state "published"
  end

  factory :archived_news_article, parent: :news_article do
    state "archived"
  end
end