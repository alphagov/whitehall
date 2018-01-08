class Admin::NewsArticlesController < Admin::EditionsController
private

  def edition_class
    NewsArticle
  end
end
