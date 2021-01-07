class WorldLocationEmailSignup
  attr_reader :feed

  def initialize(feed)
    @feed = feed
  end

  def slug
    subscriber_list = Services.email_alert_api.find_or_create_subscriber_list(criteria)
    subscriber_list["subscriber_list"]["slug"]
  end

  delegate :name, to: :world_location

  def valid?
    uri && world_location_slug && world_location.present?
  end

private

  def criteria
    {
      "links" => {
        "world_locations" => [
          world_location.content_id,
        ],
      },
    }.merge("title" => world_location.name)
  end

  def world_location
    @world_location ||= WorldLocation.find_by(slug: uri.path.match(%r{^/world/(.*)\.atom$})[1])
  end

  def uri
    @uri ||= begin
               URI.parse(feed)
             rescue URI::InvalidURIError
               nil
             end
  end

  def world_location_slug
    uri.path.match(%r{^/world/(.*)\.atom$}).try(:[], 1)
  end
end
