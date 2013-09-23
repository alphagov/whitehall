class PublicUploadsController < ApplicationController
  include ActionView::Helpers::AssetTagHelper

  def show
    if attachment_visible?
      expires_headers
      send_file_for_mime_type
    else
      fail
    end
  end

  private

  def fail
    if image? upload_path
      redirect_to view_context.path_to_image('thumbnail-placeholder.png')
    else
      redirect_to placeholder_url
    end
  end

  def redirect_to_placeholder
    redirect_to placeholder_url
  end

  def send_file_for_mime_type
    if mime_type = mime_type_for(upload_path)
      send_file real_path_for_x_accel_mapping(upload_path), type: mime_type, disposition: 'inline'
    else
      send_file real_path_for_x_accel_mapping(upload_path), disposition: 'inline'
    end
  end

  def image?(path)
    ['.jpg', '.jpeg', '.png', '.gif'].include?(File.extname(path))
  end

  def mime_type_for(path)
    Mime::Type.lookup_by_extension(File.extname(path).from(1).downcase)
  end

  def expires_headers
    expires_in(Whitehall.default_cache_max_age, public: true)
  end

  def upload_path
    basename = [params[:path], params[:extension]].join(".")
    File.join(Whitehall.clean_uploads_root, basename)
  end

  def attachment_visible?
    upload_exists? upload_path
  end

  def upload_exists?(path)
    File.exists?(path) && file_is_clean?(path)
  end

  def file_is_clean?(path)
    path.starts_with?(Whitehall.clean_uploads_root)
  end

  def real_path_for_x_accel_mapping(potentially_symlinked_path)
    File.realpath(potentially_symlinked_path)
  end
end
