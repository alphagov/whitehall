module CacheControlHelper
  def expire_on_next_scheduled_publication(scheduled_editions)
    soonest = scheduled_editions.map(&:seconds_until_scheduled_publication).compact.min
    expires_in(soonest, public: true) if soonest
  end
end