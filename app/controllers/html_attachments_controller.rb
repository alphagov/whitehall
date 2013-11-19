class HtmlAttachmentsController < ApplicationController
  include PublicDocumentRoutesHelper

  layout 'html_attachments'

  before_filter :find_edition, :redirect_if_unpublished, :find_html_attachment

  def show
  end

private

  def find_edition
    if previewing?
      @edition = Document.at_slug(document_class, slug_param).latest_edition
    else
      @edition = document_class.published_as(slug_param)
    end
  end

  def redirect_if_unpublished
    return if @edition

    if unpublishing = Unpublishing.from_slug(slug_param, document_class)
      redirect_to public_document_path(unpublishing.edition)
    else
      raise ActiveRecord::RecordNotFound, "could not find Edition with slug #{slug_param}"
    end
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
