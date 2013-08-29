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
  end

  private

  def find_edition
    if previewing?
      @edition = Document.at_slug(edition_class, edition_slug).latest_edition
    else
      @edition = edition_class.published_as(edition_slug)
    end

    render text: "Not found", status: :not_found unless @edition
  end

  def find_html_version
    if previewing?
      @html_version = HtmlVersion.find(params[:preview])
    else
      @html_version = HtmlVersion.where(edition_id: @edition, slug: params[:id]).first
    end

    render(text: "Not found", status: :not_found) unless @html_version
  end

  def analytics_format
    @edition.type.underscore.to_sym
  end

  def previewing?
    user_signed_in? && params[:preview]
  end

  def edition_class
    params[:publication_id] ? Publication : Consultation
  end

  def edition_slug
    params[:publication_id] || params[:consultation_id]
  end
end
