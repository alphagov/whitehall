class LandingPage < Edition
  include ::Attachable
  include Edition::Organisations
  include Edition::Images

  skip_callback :validation, :before, :update_document_slug
  validates :base_path, presence: true, format: { with: /\A\/.*\z/, message: "must start with a slash (/)" }
  validate :base_path_must_not_be_taken
  validate do
    if landing_page_body.invalid?
      errors.add(:body, "contained errors")
      errors.merge!(landing_page_body.errors)
    end
  end

  def publishing_api_presenter
    PublishingApi::LandingPagePresenter
  end

  def rendering_app
    Whitehall::RenderingApp::FRONTEND
  end

  def base_path
    slug
  end

  def self.access_limited_by_default?
    true
  end

  def permitted_image_usages
    super + [
      ImageUsage.new(
        key: "hero",
        label: "hero",
        kinds: Whitehall.image_kinds.values.select { _1.permitted_uses.include? "hero" },
        multiple: true,
      ),
      ImageUsage.new(
        key: "landing_page",
        label: "landing page",
        kinds: Whitehall.image_kinds.values.select { _1.permitted_uses.include? "landing_page" },
        multiple: true,
      ),
    ]
  end

  def landing_page_body
    if @landing_page_body&.raw_body == body
      @landing_page_body
    else
      @landing_page_body = LandingPage::Body.new(body, images)
    end
  end

private

  def base_path_must_not_be_taken
    errors.add(:base_path, " is already taken") if Document.where(slug:).where.not(id: document.id).exists?
  end
end
