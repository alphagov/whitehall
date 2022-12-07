class Admin::DocumentsController < Admin::BaseController
  before_action :find_document, only: %i[edit_slug update_slug]
  before_action :find_published_edition, only: %i[edit_slug update_slug]
  before_action :enforce_permissions!, only: %i[edit_slug update_slug]
  layout "design_system"

  def by_content_id
    document = (
      Document.find_by(content_id: params[:content_id]) ||
      # If the content_id doesn't match a document, it could be a HTML
      # attachment
      HtmlAttachment.find_by(content_id: params[:content_id])&.attachable&.document
    )

    url_maker = Whitehall::UrlMaker.new(host: Plek.find("whitehall"))
    if document
      redirect_to url_maker.admin_edition_path(document.latest_edition)
    else
      flash[:error] = "The requested content was not found"
      redirect_to url_maker.admin_editions_path
    end
  end

  def edit_slug; end

  def update_slug
    @document.assign_attributes(slug: params.dig("document", "slug"))

    if DataHygiene::DocumentReslugger.new(@document, @published_edition, current_user, params.dig("document", "slug")).run!
      flash[:notice] = "Slug updated successfully"
      redirect_to admin_edition_path(@published_edition)
    else
      render :edit_slug
    end
  end

private

  def find_document
    @document = Document.find(params[:id])
  end

  def find_published_edition
    @published_edition = @document.editions.published.last
  end

  def enforce_permissions!
    enforce_permission!(:perform_administrative_tasks, @document)
  end
end
