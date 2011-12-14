class Admin::NewsArticlesController < Admin::DocumentsController
  include Admin::DocumentsController::Featurable

  private

  def document_class
    NewsArticle
  end
end