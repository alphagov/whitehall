class HtmlAttachmentsController < PublicFacingController
  include PublicDocumentRoutesHelper
  include PermissionsChecker

  layout 'html_attachments'

  before_action :find_edition, :redirect_if_unpublished, :find_html_attachment
  around_action :set_locale_from_attachment

  def show
    set_meta_description(@edition.summary)
  end

private

  def set_cache_control_headers
    if previewing?
      expires_now
    else
      super
    end
  end

  def find_edition
    if previewing?
      @edition = Document.at_slug(document_class, slug_param).try(:latest_edition)
      render_not_found unless can_preview?(@edition)
    else
      @edition = document_class.published_as(slug_param)
    end
  end

  def redirect_if_unpublished
    return if @edition

    if unpublishing = Unpublishing.from_slug(slug_param, document_class)
      redirect_to unpublishing.document_path
    else
      render_not_found
    end
  end

  def find_html_attachment
    if previewing?
      @html_attachment = @edition.html_attachments.find(params[:preview])
    else
      @html_attachment = @edition.html_attachments.find(params[:id])
    end
  end

  def slug_param
    params[:publication_id] ? params[:publication_id] : params[:consultation_id]
  end

  def document_class
    params[:publication_id] ? Publication : Consultation
  end

  def previewing?
    user_signed_in? && params[:preview]
  end

  def set_locale_from_attachment(&block)
    I18n.with_locale(@html_attachment.locale || I18n.default_locale, &block)
  end
end
