class HtmlVersionsController < PublicFacingController
  layout 'html-publication'

  before_filter :find_publication
  before_filter :find_html_version

  include CacheControlHelper
  include PublicDocumentRoutesHelper

  def set_slimmer_template
    slimmer_template('chromeless')
  end

  def show
    @document = @publication
    @html_version = @publication.html_version
  end

  private

  def find_publication
    unless @publication = Publication.published_as(params[:publication_id])
      render text: "Not found", status: :not_found
    end
  end

  def find_html_version
    unless @publication.html_version && (params[:id] == @publication.html_version.slug)
      render text: "Not found", status: :not_found
    end
  end

  def analytics_format
    :publication
  end
end
