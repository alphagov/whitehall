class Admin::DocumentsController < Admin::BaseController
  def by_content_id
    document = Document.find_by(content_id: params[:content_id])
    url_maker = Whitehall::UrlMaker.new(host: Plek.find('whitehall'))
    if document
      redirect_to url_maker.admin_edition_path(document.latest_edition)
    else
      flash[:error] = "The requested content was not found"
      redirect_to url_maker.admin_editions_path
    end
  end
end
