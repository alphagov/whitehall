class LandingPage::Body
  include ActiveModel::API

  attr_reader :raw_body, :body, :extends, :breadcrumbs, :navigation_groups, :blocks

  validates :blocks, presence: true
  validate :validate_extends_document_exists
  validate do
    blocks.each { |b| errors.merge!(b.errors) if b.invalid? }
  end

  def initialize(raw_body)
    @raw_body = raw_body

    @yaml_errors = []
    @body = begin
      YAML.load(@raw_body)
    rescue StandardError => e
      @yaml_errors << e
      {}
    end
    @extends = body["extends"]
    extend_body
    @breadcrumbs = body["breadcrumbs"]
    @navigation_groups = body["navigation_groups"]
    @blocks = LandingPage::BlockFactory.build_all(body["blocks"])
  end

  def present_for_publishing_api
    {
      breadcrumbs:,
      navigation_groups:,
      blocks: blocks.map(&:present_for_publishing_api),
    }
  end

  def body_to_extend
    @body_to_extend ||= begin
      return if extends.blank?

      edition = Document.find_by(slug: extends)&.latest_edition
      return if edition.nil?

      parsed_body = begin
        YAML.safe_load(edition.body, permitted_classes: [Date])
      rescue StandardError
        nil
      end
      parsed_body if parsed_body.is_a?(Hash)
    end
  end

  def validate_extends_document_exists
    return unless extends.present? && body_to_extend.nil?

    errors.add(:body, "extends #{extends} but that document does not exist, or does not have a YAML body")
  end

  def extend_body
    return if body_to_extend.nil?

    body.reverse_merge!(body_to_extend)
  end
end
