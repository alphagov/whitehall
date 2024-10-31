class LandingPage < Edition
  include ::Attachable
  include Edition::Organisations
  include Edition::Images

  skip_callback :validation, :before, :update_document_slug
  validates :base_path, presence: true
  validate :base_path_must_not_be_taken
  validate :body_must_be_valid_yaml

  def valid_image_dimensions(key)
    all_valid_image_dimensions[key]
  end

  def all_valid_image_dimensions
    super.merge(
      "Mobile hero image (2x pixel density)" => Edition::Images::Dimensions.new(width: 1280, height: 854),
      "Tablet hero image (2x pixel density)" => Edition::Images::Dimensions.new(width: 1536, height: 1024),
      "Desktop hero image (2x pixel density)" => Edition::Images::Dimensions.new(width: 3840, height: 1220),
    )
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
