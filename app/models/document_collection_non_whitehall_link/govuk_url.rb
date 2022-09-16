class DocumentCollectionNonWhitehallLink::GovukUrl
  include ActiveModel::Validations

  attr_reader :url, :document_collection_group

  validates :url, presence: true
  validates :document_collection_group, presence: true
  validate :is_internal_url?
  validates_with GovUkUrlValidator

  def initialize(url:, document_collection_group:)
    @url = url
    @document_collection_group = document_collection_group
  end

  def save
    return unless valid?

    non_whitehall_link = DocumentCollectionNonWhitehallLink.create!(
      content_item.slice("base_path", "content_id", "publishing_app", "title"),
    )

    document_collection_group.memberships.create!(non_whitehall_link:)
  end

  def title
    content_item["title"]
  end

  def is_internal_url?
    message = "must be a valid GOV.UK URL"
    unless govuk_url?
      errors.add(:url, message)
    end
  rescue URI::InvalidURIError
    errors.add(:url, message)
  end

private

  def content_item
    @content_item ||= Services.publishing_api.get_content(content_id).to_h
  end

  def content_id
    @content_id ||= Services.publishing_api.lookup_content_id(base_path: parsed_url.path, with_drafts: true)
  end

  def govuk_url?
    govuk_url_regex.match?(parsed_url.host)
  end

  def govuk_url_regex
    /(publishing.service|www).gov.uk\Z/
  end

  def parsed_url
    URI.parse(url)
  end
end
