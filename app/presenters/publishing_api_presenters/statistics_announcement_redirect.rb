require "securerandom"
require_relative "../publishing_api_presenters"

class PublishingApiPresenters::StatisticsAnnouncementRedirect
  extend Forwardable
  def_delegators :item, :base_path, :publication

  attr_reader :content_id, :item

  def initialize(item, _options = {})
    @item = item
    @content_id = SecureRandom.uuid
  end

  def content
    {
      base_path: base_path,
      format: "redirect",
      publishing_app: "whitehall",
      redirects: [
        {
          path: base_path,
          destination: Addressable::URI.parse(redirect_url).path,
          type: "exact"
        }
      ]
    }
  end

  def update_type
    "major"
  end

  def links
    # no tags
    {}
  end

private

  def redirect_url
    publication_is_published? ? publication_url : item.redirect_url
  end

  def publication_is_published?
    item.publication && item.publication.published?
  end

  def publication_url
    Whitehall.url_maker.public_document_path(item.publication)
  end
end
