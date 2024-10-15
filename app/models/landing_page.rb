class LandingPage < Edition
  skip_callback :validation, :before, :update_document_slug

  def publishing_api_presenter
    PublishingApi::LandingPagePresenter
  end

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end

  def base_path
    slug
  end
end
