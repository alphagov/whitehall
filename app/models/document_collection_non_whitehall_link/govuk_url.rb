class DocumentCollectionNonWhitehallLink::GovukUrl
  include ActiveModel::Validations

  attr_reader :url, :document_collection_group

  validates_presence_of :url
  validates_presence_of :document_collection_group
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

    document_collection_group.memberships.create!(non_whitehall_link: non_whitehall_link)
  end

  def title
    content_item["title"]
  end

  private

  def content_item
    @content_item ||= Services.publishing_api.get_content(content_id).to_h
  end

  def content_id
    @content_id ||= Services.publishing_api.lookup_content_id(base_path: parsed_url.path, with_drafts: true)
  end

  def parsed_url
    URI.parse(url)
  end
end
