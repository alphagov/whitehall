class HtmlVersionsController < PublicFacingController
  layout 'html-publication'

  before_filter :find_edition
  before_filter :find_html_version

  include CacheControlHelper
  include PublicDocumentRoutesHelper

  def set_slimmer_template
    slimmer_template('chromeless')
  end

  def show
    @document = @edition
    @html_version = @edition.html_version
  end

  private

  def find_edition
    if (params[:publication_id])
      @edition = Publication.published_as(params[:publication_id])
    elsif (params[:consultation_id])
      @edition = Consultation.published_as(params[:consultation_id])
    end

    render text: "Not found", status: :not_found unless @edition
  end

  def find_html_version
    unless @edition.html_version && (params[:id] == @edition.html_version.slug)
      render text: "Not found", status: :not_found
    end
  end

  def analytics_format
    @edition.type.underscore.to_sym
  end
end
