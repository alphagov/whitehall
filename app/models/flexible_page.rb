class FlexiblePage < Edition
  validates :flexible_page_type, presence: true, inclusion: { in: -> { FlexiblePageType.all_keys } }

  def self.choose_document_type_form_action
    "choose_type_admin_flexible_pages_path"
  end

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
