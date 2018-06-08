class BaseAttachmentsController < ApplicationController
protected

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

  def redirect_to_placeholder
    # Cache is explicitly 1 minute to prevent the virus redirect beng
    # cached by CDNs.
    expires_in(1.minute, public: true)
    redirect_to placeholder_url
  end
end
