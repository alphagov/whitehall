class AttachmentsController < PublicUploadsController
  include PublicDocumentRoutesHelper

  layout 'html-publication', only: [:show_html]

  before_filter :find_edition, only: [:show_html]
  before_filter :find_html_attachment, only: [:show_html]

  private

  def attachment_visible?
    super && attachment_visibility.visible?
  end

  def fail
    if edition = attachment_visibility.unpublished_edition
      redirect_to public_document_path(edition, id: edition.unpublishing.slug)
    elsif replacement = attachment_data.replaced_by
      redirect_to replacement.url, status: 301
    else
      super
    end
  end

  def analytics_format
    @edition.type.underscore.to_sym
  end

  def set_slimmer_template
    slimmer_template('chromeless')
  end

  def previewing?
    user_signed_in? && params[:preview]
  end

  def edition_slug
    params[:publication_id] || params[:consultation_id]
  end

  def find_edition
    cls = params[:publication_id] ? Publication : Consultation
    @edition = if previewing?
      Document.at_slug(cls, edition_slug).latest_edition
    else
      cls.published_as(edition_slug)
    end
    @edition.nil? && raise(ActiveRecord::RecordNotFound)
  end

  def find_html_attachment
    @attachment = if previewing?
      HtmlAttachment.find(params[:preview])
    else
      @edition.attachments.where(slug: params[:id]).first
    end
    @attachment.nil? && raise(ActiveRecord::RecordNotFound)
  end

  def attachment_data
    @attachment_data ||= AttachmentData.find(params[:id])
  end

  def expires_headers
    if current_user.nil?
      super
    else
      response.headers['Cache-Control'] = 'no-cache, max-age=0, private'
    end
  end

  def upload_path
    File.join(Whitehall.clean_uploads_root, path_to_attachment_or_thumbnail)
  end

  def file_with_extensions
    [params[:file], params[:extension]].join('.')
  end

  def path_to_attachment_or_thumbnail
    attachment_data.file.store_path(file_with_extensions)
  end

  def attachment_visibility
    @attachment_visibility ||= AttachmentVisibility.new(attachment_data, current_user)
  end
end
