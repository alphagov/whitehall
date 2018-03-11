class AttachmentsController < ApplicationController
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

  def attachment_visible?
    upload_exists?(upload_path) && attachment_visibility.visible?
  end

  def fail
    if (edition = attachment_visibility.unpublished_edition)
      redirect_to edition.unpublishing.document_path
    elsif (replacement = attachment_data.replaced_by)
      expires_headers
      redirect_to replacement.url, status: 301
    elsif image? upload_path
      redirect_to view_context.path_to_image('thumbnail-placeholder.png')
    elsif incoming_upload_exists? upload_path
      redirect_to_placeholder
    else
      render plain: "Not found", status: :not_found
    end
  end

  def link_rel_headers
    if (edition = attachment_visibility.visible_edition)
      response.headers['Link'] = "<#{public_document_url(edition)}>; rel=\"up\""
    end
  end

  def set_slimmer_template
    slimmer_template 'chromeless'
  end

  def attachment_data
    @attachment_data ||= AttachmentData.find(params[:id])
  end

  def expires_headers
    if current_user.nil?
      expires_in(Whitehall.uploads_cache_max_age, public: true)
    else
      expires_now
    end
  end

  def upload_path
    File.join(Whitehall.clean_uploads_root, path_to_attachment_or_thumbnail)
  end

  def file_with_extensions
    [params[:file], params[:extension], params[:format]].compact.join('.')
  end

  def path_to_attachment_or_thumbnail
    attachment_data.file.store_path(file_with_extensions)
  end

  def attachment_visibility
    @attachment_visibility ||= AttachmentVisibility.new(attachment_data, current_user)
  end

  def file_is_clean?(path)
    path.starts_with?(Whitehall.clean_uploads_root)
  end

  def image?(path)
    ['.jpg', '.jpeg', '.png', '.gif'].include?(File.extname(path))
  end

  def incoming_upload_exists?(path)
    path = path.sub(Whitehall.clean_uploads_root, Whitehall.incoming_uploads_root)
    File.exist?(path)
  end

  def mime_type_for(path)
    Mime::Type.lookup_by_extension(File.extname(path).from(1).downcase)
  end

  def real_path_for_x_accel_mapping(potentially_symlinked_path)
    File.realpath(potentially_symlinked_path)
  end

  def redirect_to_placeholder
    # Cache is explicitly 1 minute to prevent the virus redirect beng
    # cached by CDNs.
    expires_in(1.minute, public: true)
    redirect_to placeholder_url
  end

  def send_file_for_mime_type
    if (mime_type = mime_type_for(upload_path))
      send_file real_path_for_x_accel_mapping(upload_path), type: mime_type, disposition: 'inline'
    else
      send_file real_path_for_x_accel_mapping(upload_path), disposition: 'inline'
    end
  end

  def upload_exists?(path)
    File.exist?(path) && file_is_clean?(path)
  end
end
