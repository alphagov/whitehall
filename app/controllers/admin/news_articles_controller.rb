class Admin::NewsArticlesController < Admin::DocumentsController

  private

  def document_class
    NewsArticle
  end
end