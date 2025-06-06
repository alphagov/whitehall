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
            :title,
            :internal_change_note,
            :change_note,
            :major_change,
            document_attributes: %w[block_type],
            details: @schema.permitted_params,
          )
          .merge!(creator: current_user)
  end

  def set_sentry_tags
    Sentry.set_tags(engine: "content_block_manager")
  end

  delegate :product_name, to: :ContentBlockManager

  delegate :support_url, to: :ContentBlockManager
  helper_method :support_url

  # This ensures we can override views if we need to without altering the Engine's load order, which
  # may have unintended consequences
  def prepend_views
    prepend_view_path Rails.root.join("lib/engines/content_block_manager/app/views")
  end
end
