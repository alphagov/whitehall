class DocumentCollectionNonWhitehallLink::GovukUrl
  include ActiveModel::Validations

  attr_reader :url, :document_collection_group

  validates :url, presence: true
  validates :document_collection_group, presence: true
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

  def parsed_url
    @parsed_url ||= URI.parse(url)
  end

  def content_item
    @content_item ||= content_item_from_content_store
  end

  def content_id
    @content_id ||= content_item["content_id"]
  end

  def content_item_from_content_store
    path = parsed_url.path

    item = Services.content_store.content_item(path).to_h

    if item["base_path"] != path && item["document_type"] != "guide"
      raise GdsApi::HTTPNotFound, 404
    end

    item
  rescue GdsApi::ContentStore::ItemNotFound
    raise GdsApi::HTTPNotFound, 404
  end
end
