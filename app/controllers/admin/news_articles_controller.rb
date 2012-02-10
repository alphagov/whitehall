class Admin::NewsArticlesController < Admin::DocumentsController
  before_filter :build_image, only: [:new, :edit]

  private

  def document_class
    NewsArticle
  end
end