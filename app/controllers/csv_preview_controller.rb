class CsvPreviewController < ApplicationController
  slimmer_template "chromeless"

  def show
    respond_to do |format|
      format.html do
        @csv_response = CsvFileFromPublicHost.csv_response(attachment_data.file.asset_manager_path)

        if attachment_data.csv? && attachment_visible? && visible_or_draft_edition_present?
          expires_headers
          @csv_preview = CsvFileFromPublicHost.csv_preview_from(@csv_response)
          @page_base_href = Plek.new.website_root

          if draft_assets_request_and_draft_edition_present?
            @attachment = attachment_data.draft_attachment_for(current_user)
            @edition = draft_edition
            render layout: "draft_html_attachments"
          else
            @attachment = attachment_data.visible_attachment_for(current_user)
            @edition = visible_edition
            render layout: "html_attachments"
          end
        else
          fail
        end
      end
    end
  end

private

  def fail
    if attachment_data.unpublished?
      redirect_url = attachment_data.unpublished_edition.unpublishing.document_path
      redirect_to redirect_url
    elsif attachment_data.replaced?
      expires_headers
      redirect_to attachment_data.replaced_by.url, status: :moved_permanently, allow_other_host: true
    elsif incoming_upload_exists?
      redirect_to_placeholder
    else
      render plain: "Not found", status: :not_found
    end
  end

  def attachment_visible?
    upload_exists? && attachment_data.visible_to?(current_user)
  end

  def visible_edition
    @visible_edition ||= attachment_data.visible_edition_for(current_user)
  end

  def incoming_upload_exists?
    (@csv_response.status == 302) && redirect_path_matches_placeholder_path
  end

  def redirect_path_matches_placeholder_path
    URI.parse(@csv_response.headers["Location"]).path == placeholder_path
  end

  def upload_exists?
    @csv_response.status == 206
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
    redirect_to placeholder_path
  end

  def visible_or_draft_edition_present?
    draft_assets_request_and_draft_edition_present? || assets_request_and_visible_edition_present?
  end

  def draft_assets_request_and_draft_edition_present?
    draft_edition.present? && hostname_starts_with_draft_assets?
  end

  def assets_request_and_visible_edition_present?
    visible_edition.present? && !hostname_starts_with_draft_assets?
  end

  def draft_edition
    @draft_edition ||= attachment_data.draft_edition_for(current_user)
  end

  def hostname_starts_with_draft_assets?
    request.hostname.start_with? "draft-assets"
  end
end
