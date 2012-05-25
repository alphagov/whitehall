class Admin::NewsArticlesController < Admin::EditionsController
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    NewsArticle
  end
end