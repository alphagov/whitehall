class Api::NewsArticlesController < ApplicationController
  def show
    document = Document.find_by(slug: params[:slug])
    return render "admin/errors/not_found", status: :not_found unless document and document.document_type == 'NewsArticle'

    presenter = Api::NewsArticlePresenter.new(document.live_edition)
    render json: presenter.content
  end
end
