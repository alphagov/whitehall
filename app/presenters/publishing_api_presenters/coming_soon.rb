# A temporary content format used as a splash page for scheduled documents.
#
# When a new document is scheduled for publication, a "coming_soon" content item
# is pushed to the Publishing API, along with a `PublishIntent` for the
# scheduled publication time. This is to get around the fact that the current
# caching infrastructure will cache a 404 for 30 minutes without honouring any
# upstream caching headers it receives. By publishing a temporary "coming soon"
# page, we can get around this issue and ensure that the cache headers that are
# set according to the scheduled publication time will be honored, thus
# preventing a 404 page from being cached for up to 30 minutes from the point
# the document was published.
#
# Note this format becomes redundant once the caching infrasture is able to
# honour caching headers on upstream 404 responses.
class PublishingApiPresenters::ComingSoon
  attr_reader :edition, :update_type

  def initialize(edition, options = {})
    @edition = edition
    @update_type = options[:update_type] || default_update_type
  end

  def base_path
    Whitehall.url_maker.public_document_path(edition)
  end

  def as_json
    {
      base_path: base_path,
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: I18n.locale.to_s,
      update_type: update_type,
      details: {
        publish_time: edition.scheduled_publication,
      },
      routes: [
        {
          path: base_path,
          type: "exact"
        }
      ]
    }
  end

private

  def default_update_type
    'major'
  end
end

