class HmrcAssetsController < ApplicationController
  def show
    if File.exist?(upload_path)
      expires_headers
      send_file_for_mime_type
    else
      render plain: "Not found", status: :not_found
    end
  end

private

  def send_file_for_mime_type
    if (mime_type = mime_type_for(upload_path))
      send_file real_path_for_x_accel_mapping(upload_path), type: mime_type, disposition: 'inline'
    else
      send_file real_path_for_x_accel_mapping(upload_path), disposition: 'inline'
    end
  end

  def mime_type_for(path)
    Mime::Type.lookup_by_extension(File.extname(path).from(1).downcase)
  end

  def expires_headers
    expires_in(Whitehall.uploads_cache_max_age, public: true)
  end

  def upload_path
    basename = [params[:path], params[:format]].compact.join('.')
    File.join(Whitehall.clean_uploads_root, 'uploaded', 'hmrc', basename)
  end

  def real_path_for_x_accel_mapping(potentially_symlinked_path)
    File.realpath(potentially_symlinked_path)
  end
end
