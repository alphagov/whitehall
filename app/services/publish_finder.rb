class PublishFinder
  attr_reader :finder_content_item

  def initialize(finder_content_item)
    @finder_content_item = finder_content_item
  end

  def self.call(finder_content_item)
    new(finder_content_item).call
  end

  def call
    send_to_publishing_api
    send_to_rummager
  end

private

  def send_to_publishing_api
    Services.publishing_api.put_content(
      content_id,
      finder_content_item
    )
    Services.publishing_api.publish(content_id)
  end

  def send_to_rummager
    index = Whitehall::SearchIndex.for(:government)
    index.add(present_for_rummager)
  end

  def present_for_rummager
    {
      _id: finder_content_item.fetch("base_path"),
      link: finder_content_item.fetch("base_path"),
      format: "finder",
      title: finder_content_item.fetch("title"),
      description: finder_content_item.fetch("description", ""),
      content_store_document_type: finder_content_item.fetch("document_type"),
      content_id: content_id,
      publishing_app: finder_content_item.fetch("publishing_app"),
      rendering_app: finder_content_item.fetch("rendering_app"),
    }
  end

  def content_id
    @content_id ||= existing_content_id || SecureRandom.uuid
  end

  def existing_content_id
    Services.publishing_api.lookup_content_id(base_path: finder_content_item['base_path'])
  end
end
