class LandingPage::Body
  include ActiveModel::API

  attr_reader :raw_body, :extends, :breadcrumbs, :navigation_groups, :blocks

  validates :blocks, presence: true
  validate :extends_a_document_which_exists

  def initialize(raw_body)
    @raw_body = raw_body

    @yaml_errors = []
    body = begin
      YAML.load(@raw_body)
    rescue StandardError => e
      @yaml_errors << e
      {}
    end
    @extends = body["extends"]
    @breadcrumbs = body["breadcrumbs"]
    @navigation_groups = body["navigation_groups"]
    @blocks = body["blocks"]
  end

  def extends_a_document_which_exists
    return unless extends.present?

    errors.add(:body, "extends #{extends} but that document does not exist") unless Document.find_by(slug: extends)
  end
end
