class DocumentCollectionNonWhitehallLink::GovukUrl
  include ActiveModel::Validations

  attr_reader :url, :document_collection_group, :content_item

  validates_presence_of :url
  validates_presence_of :document_collection_group
  validate :linkable_govuk_url

  def initialize(url:, document_collection_group:)
    @url = url
    @document_collection_group = document_collection_group
  end

  def save
    return unless valid?

    non_whitehall_link = DocumentCollectionNonWhitehallLink.create!(
      content_item.slice("base_path", "content_id", "publishing_app", "title"),
    )

    document_collection_group.memberships.create!(non_whitehall_link: non_whitehall_link)
  end

  def title
    content_item["title"]
  end

private

  def linkable_govuk_url
    return if url.blank?

    parsed_url = URI.parse(url)

    unless parsed_url.host =~ /(publishing.service|www).gov.uk\Z/
      errors.add(:url, "must be a valid GOV.UK URL")
      return
    end

    content_id = Services.publishing_api.lookup_content_id(base_path: parsed_url.path,
                                                           with_drafts: true)
    unless content_id
      errors.add(:url, "must reference a GOV.UK page")
      return
    end

    @content_item = Services.publishing_api.get_content(content_id).to_h
  rescue URI::InvalidURIError
    errors.add(:url, "must be a valid GOV.UK URL")
  rescue GdsApi::HTTPNotFound
    errors.add(:url, "must reference a GOV.UK page")
  rescue GdsApi::HTTPIntermittentServerError
    errors.add(:base, "Link lookup failed, please try again later")
  end
end
