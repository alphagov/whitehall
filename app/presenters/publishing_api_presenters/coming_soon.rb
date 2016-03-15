require "securerandom"
require_relative "../publishing_api_presenters"

# A temporary content format used as a splash page for scheduled documents.
#
# When a piece of content is scheduled for publication, a "coming_soon" content
# item is pushed to the Publishing API, along with a `PublishIntent` for the
# scheduled publication time. This is to get around the fact that the current
# caching infrastructure will cache a 404 for 30 minutes without honouring any
# upstream caching headers it receives. By publishing a temporary "coming soon"
# page, we can get around this issue and ensure that the cache headers that are
# set according to the scheduled publication time will be honored, thus
# preventing a 404 page from being cached for up to 30 minutes from the point
# the document was published.
#
# Note this format becomes redundant once the caching infrastructure is able to
# honour caching headers on upstream 404 responses.

class PublishingApiPresenters::ComingSoon < PublishingApiPresenters::Item
  def content_id
    SecureRandom.uuid
  end

  private

  def filter_links
    []
  end

  def document_format
    'coming_soon'
  end

  def title
    'Coming soon'
  end

  def description
    'Coming soon'
  end

  def rendering_app
    item.rendering_app
  end

  def details
    { publish_time: item.scheduled_publication.as_json }
  end

  def public_updated_at
    item.updated_at
  end

  def base_path
    Whitehall.url_maker.public_document_path(item, locale: I18n.locale)
  end
end
