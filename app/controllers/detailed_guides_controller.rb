class DetailedGuidesController < DocumentsController
  skip_before_filter :set_search_path
  before_filter :set_expiry, only: [:show]
  before_filter :set_analytics_format, only: [:show]

  def show
    @topics = @document.topics
    @related_policies = document_related_policies

    set_meta_description(@document.summary)
  end

private
  def document_class
    DetailedGuide
  end

  def analytics_format
    :detailed_guidance
  end

  def canonical_redirect_path(redir_params)
    # There's no index for detailed guides, so we don't need to worry
    # about this complaing about a lack of id
    detailed_guide_url(redir_params.except(:controller, :action))
  end
end
