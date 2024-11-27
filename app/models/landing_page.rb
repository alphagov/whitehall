class LandingPage < Edition
  include ::Attachable
  include Edition::Organisations
  include Edition::Images

  skip_callback :validation, :before, :update_document_slug
  validates :base_path, presence: true, format: { with: /\A\/.*\z/, message: "must start with a slash (/)" }
  validate :base_path_must_not_be_taken
  validate :body_must_be_valid_yaml

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

  def permitted_image_kinds
    super + Whitehall.image_kinds.values.select { _1.permitted_uses.intersect?(%w[hero landing_page]) }
  end

private

  def base_path_must_not_be_taken
    errors.add(:base_path, " is already taken") if Document.where(slug:).where.not(id: document.id).exists?
  end

  def body_must_be_valid_yaml
    body_hash = YAML.load(body)
    unless body_hash.keys.include?("blocks")
      errors.add(:body, "must contain a root element 'blocks:'")
    end
    if body_hash.key?("extends") && Document.find_by(slug: body_hash["extends"]).nil?
      errors.add(:body, "extends #{body_hash.keys['extends']} but that document does not exist")
    end
  rescue StandardError => e
    errors.add(:body, "must be valid YAML: #{e.message}")
  end
end
