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
# Note this format becomes redundant once the caching infrasture is able to
# honour caching headers on upstream 404 responses.
class PublishingApiPresenters::ComingSoon
  attr_reader :base_path, :publishing_timestamp, :locale

  def initialize(base_path, publishing_timestamp, locale)
    @base_path = base_path
    @publishing_timestamp = publishing_timestamp
    @locale = locale
  end

  def as_json
    {
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      format: 'coming_soon',
      title: 'Coming soon',
      locale: locale,
      update_type: 'major',
      details: { publish_time: publishing_timestamp },
      routes: [ { path: base_path, type: "exact" } ]
    }
  end
end
