class FlexiblePage < Edition
  def publishing_api_presenter
    PublishingApi::FlexiblePagePresenter
  end

  def summary_required?
    false
  end

  def body_required?
    false
  end

  def can_set_previously_published?
    false
  end

  def previously_published
    false
  end

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end
end
