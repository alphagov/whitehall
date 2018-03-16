class BaseAttachmentsController < ApplicationController
protected

  def attachment_visible?
    clean? && attachment_data.visible_to?(current_user)
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
    @upload_path ||= File.join(Whitehall.clean_uploads_root, path_to_attachment_or_thumbnail)
  end

  def file_with_extensions
    [params[:file], params[:extension], params[:format]].compact.join('.')
  end

  def path_to_attachment_or_thumbnail
    attachment_data.file.store_path(file_with_extensions)
  end

  def image?
    ['.jpg', '.jpeg', '.png', '.gif'].include?(File.extname(upload_path))
  end

  def unscanned?
    path = upload_path.sub(Whitehall.clean_uploads_root, Whitehall.incoming_uploads_root)
    File.exist?(path)
  end

  def redirect_to_placeholder
    # Cache is explicitly 1 minute to prevent the virus redirect beng
    # cached by CDNs.
    expires_in(1.minute, public: true)
    redirect_to placeholder_url
  end

  def clean?
    File.exist?(upload_path)
  end
end
