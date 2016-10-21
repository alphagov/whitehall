class PublishFinder
  attr_reader :finder_content_item

  def initialize(finder_content_item)
    @finder_content_item = finder_content_item
  end

  def self.call(finder_content_item)
    new(finder_content_item).call
  end

  def call
    Whitehall.publishing_api_v2_client.put_content(
      content_id,
      finder_content_item
    )
    Whitehall.publishing_api_v2_client.publish(content_id, "major")
  end

private

  def content_id
    @content_id ||= existing_content_id || SecureRandom.uuid
  end

  def existing_content_id
    Whitehall
      .publishing_api_v2_client
      .lookup_content_id(base_path: finder_content_item['base_path'])
  end
end
