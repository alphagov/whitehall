class Admin::NewsArticlesController < Admin::DocumentsController

  def feature
    document_class.find(params[:id]).update_attribute(:featured, true)
    redirect_to :back
  end

  def unfeature
    document_class.find(params[:id]).update_attribute(:featured, false)
    redirect_to :back
  end

  private

  def document_class
    NewsArticle
  end
end