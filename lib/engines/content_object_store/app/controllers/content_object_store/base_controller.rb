class ContentObjectStore::BaseController < Admin::BaseController
  before_action :check_object_store_feature_flag, :set_sentry_tags, :prepend_views

  def check_object_store_feature_flag
    forbidden! unless Flipflop.content_object_store?
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
    Sentry.set_tags(engine: "content_object_store")
  end

  def product_name
    "Content Object Store"
  end

  # This ensures we can override views if we need to without altering the Engine's load order, which
  # may have unintended consequences
  def prepend_views
    prepend_view_path Rails.root.join("lib/engines/content_object_store/app/views")
  end
end
