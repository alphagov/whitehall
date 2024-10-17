class LandingPage < Edition
  include Edition::Organisations

  validates :base_path, presence: true
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

private

  def base_path_must_not_be_taken
    errors.add(:base_path, " is already taken") if Document.where(slug:).where.not(id: document.id).exists?
  end

  def body_must_be_valid_yaml
    body_hash = YAML.load(body)
    if body_hash.keys != %w[blocks]
      errors.add(:body, "root element must be 'blocks:'")
    end
  rescue StandardError => e
    errors.add(:body, "must be valid YAML: #{e.message}")
  end
end
