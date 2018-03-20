class AttachmentsController < BaseAttachmentsController
  include PublicDocumentRoutesHelper

  def show
    if attachment_visible?
      expires_headers
      send_file_for_mime_type
    else
      fail
    end
    link_rel_headers
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
