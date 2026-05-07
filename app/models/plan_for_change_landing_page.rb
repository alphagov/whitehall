class PlanForChangeLandingPage < Edition
  include ::Attachable
  include Edition::Organisations
  include Edition::Images

  validates :slug_override, presence: true
  validates :slug_override, format: { with: /\A\/.*\z/, message: "must start with a slash (/)" }, if: -> { slug_override.present? }
  validate :slug_override_must_not_be_taken
  validate do
    if landing_page_body.invalid?
      errors.add(:body, "contained errors")
      errors.merge!(landing_page_body.errors)
    end
  end

  def publishing_api_presenter
    PublishingApi::PlanForChangeLandingPagePresenter
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
        kinds: Whitehall.image_kinds.values_at("hero_desktop", "hero_tablet", "hero_mobile"),
        multiple: true,
      ),
      ImageUsage.new(
        key: "plan_for_change_landing_page",
        label: "landing page",
        kinds: Whitehall.image_kinds.values_at("landing_page_image"),
        multiple: true,
      ),
    ]
  end

  def landing_page_body
    if @landing_page_body&.raw_body == body
      @landing_page_body
    else
      @landing_page_body = PlanForChangeLandingPage::Body.new(body, images)
    end
  end

private

  def slug_override_must_not_be_taken
    errors.add(:slug_override, "is already taken") if PlanForChangeLandingPage.where(slug_override:).where.not(document_id: document_id).exists?
  end
end
