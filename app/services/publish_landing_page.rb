# NOTE: Temporary while we work out which
#       publishing app / CMS to use for landing pages
class PublishLandingPage
  attr_reader :landing_page_content_item

  def initialize(landing_page_content_item)
    @landing_page_content_item = landing_page_content_item
  end

  def self.call(landing_page_content_item)
    new(landing_page_content_item).call
  end

  def call
    send_to_publishing_api
  end

private

  def send_to_publishing_api
    Services.publishing_api.put_content(
      content_id,
      landing_page_content_item,
    )
    Services.publishing_api.publish(content_id)
  end

  def content_id
    @content_id ||= existing_content_id || SecureRandom.uuid
  end

  def existing_content_id
    Services.publishing_api.lookup_content_id(base_path: landing_page_content_item["base_path"])
  end
end
