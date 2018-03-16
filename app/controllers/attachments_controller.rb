class AttachmentsController < BaseAttachmentsController
  include PublicDocumentRoutesHelper

  def show
    if attachment_data.deleted?
      render_not_found
      return
    end

    if infected? || !exists?
      render_not_found
      return
    end

    if unscanned?
      if image?
        redirect_to view_context.path_to_image('thumbnail-placeholder.png')
      else
        redirect_to_placeholder
      end
      return
    end

    if attachment_data.unpublished?
      redirect_url = attachment_data.unpublished_edition.unpublishing.document_path
      redirect_to redirect_url
      return
    end

    if attachment_data.replaced?
      expires_headers
      redirect_to attachment_data.replaced_by.url, status: 301
      return
    end

    unless (!attachment_data.draft? || (attachment_data.draft? && attachment_data.accessible_to?(current_user)))
      render_not_found
      return
    end

    expires_headers
    link_rel_headers
    send_file_for_mime_type
  end

private

  def link_rel_headers
    if (edition = attachment_data.visible_edition_for(current_user))
      response.headers['Link'] = "<#{public_document_url(edition)}>; rel=\"up\""
    end
  end

  def mime_type_for(path)
    Mime::Type.lookup_by_extension(File.extname(path).from(1).downcase)
  end

  def real_path_for_x_accel_mapping(potentially_symlinked_path)
    File.realpath(potentially_symlinked_path)
  end

  def send_file_for_mime_type
    if (mime_type = mime_type_for(upload_path))
      send_file real_path_for_x_accel_mapping(upload_path), type: mime_type, disposition: 'inline'
    else
      send_file real_path_for_x_accel_mapping(upload_path), disposition: 'inline'
    end
  end
end
