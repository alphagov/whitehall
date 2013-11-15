class HtmlAttachmentsController < ApplicationController
  layout 'html_attachments'

  before_filter :find_edition
  before_filter :find_html_attachment

  def show
  end

private

  def find_edition
    if previewing?
      @edition = Document.at_slug(document_class, slug_param).latest_edition
    else
      @edition = document_class.published_as(slug_param)
    end

    raise ActiveRecord::RecordNotFound unless @edition
  end

  def find_html_attachment
    if previewing?
      @html_attachment = HtmlAttachment.find(params[:preview])
    else
      @html_attachment = @edition.attachments.find_by_slug!(params[:id])
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
end
