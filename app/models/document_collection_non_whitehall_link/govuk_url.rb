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
    content_id
    @content_item ||= content_item_from_content_store
  end

  def content_id
    @content_id ||= Services.publishing_api.lookup_content_id(base_path: parsed_url.path, with_drafts: true)

    if @content_id.blank?
      toplevel_path_segment = parsed_url.path.split("/").second
      @content_id = Services.publishing_api.lookup_content_id(base_path: "/#{toplevel_path_segment}", with_drafts: true)

      if @content_id.blank?
        @content_id = content_item_from_content_store["content_id"]
        raise GdsApi::HTTPNotFound, 404 if @content_id.blank?
      else
        raise GdsApi::HTTPNotFound, 404 unless content_item["document_type"] == "guide"
      end
    end

    @content_id
  end

  def content_item_from_content_store
    Services.content_store.content_item(parsed_url.path).to_h
  rescue GdsApi::ContentStore::ItemNotFound
    raise GdsApi::HTTPNotFound, 404
  end
end
