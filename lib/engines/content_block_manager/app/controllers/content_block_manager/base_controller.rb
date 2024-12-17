class ContentBlockManager::BaseController < Admin::BaseController
  before_action :check_block_manager_permissions, :set_sentry_tags, :prepend_views

  def check_block_manager_permissions
    # Temporarily disable production access for non-admin users
    forbidden! unless Whitehall.integration_or_staging? || current_user.gds_admin?
  end

  def scheduled_publication_params
    params.require(:scheduled_at).permit("scheduled_publication(1i)",
                                         "scheduled_publication(2i)",
                                         "scheduled_publication(3i)",
                                         "scheduled_publication(4i)",
                                         "scheduled_publication(5i)")
  end

  def edition_params
    params.require("content_block/edition")
          .permit(
            :organisation_id,
            :creator,
            :instructions_to_publishers,
            "scheduled_publication(1i)",
            "scheduled_publication(2i)",
            "scheduled_publication(3i)",
            "scheduled_publication(4i)",
            "scheduled_publication(5i)",
            document_attributes: %w[title block_type],
            details: @schema.fields,
          )
          .merge!(creator: current_user)
  end

  def set_sentry_tags
    Sentry.set_tags(engine: "content_block_manager")
  end

  def product_name
    "Content Block Manager"
  end

  def support_url
    "#{Plek.external_url_for('support')}/general_request/new"
  end
  helper_method :support_url

  # This ensures we can override views if we need to without altering the Engine's load order, which
  # may have unintended consequences
  def prepend_views
    prepend_view_path Rails.root.join("lib/engines/content_block_manager/app/views")
  end

  def validate_scheduled_edition
    if params[:schedule_publishing].blank?
      @content_block_edition.errors.add(:schedule_publishing, "cannot be blank")
      raise ActiveRecord::RecordInvalid, @content_block_edition
    elsif params[:schedule_publishing] == "schedule"
      @content_block_edition.assign_attributes(scheduled_publication_params)
      @content_block_edition.assign_attributes(state: "scheduled")
      raise ActiveRecord::RecordInvalid unless @content_block_edition.valid?
    end
  end
end
