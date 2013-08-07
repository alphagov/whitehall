module CacheControlHelper

  def cache_max_age
    @cache_max_age ||= Whitehall.default_cache_max_age
  end

  def expire_on_next_scheduled_publication(scheduled_editions)
    scheduled_times = scheduled_editions.map(&:scheduled_publication)
    if next_scheduled_time = scheduled_times.compact.min
      expires_in(max_age_for(next_scheduled_time), public: true)
    end
  end

  def max_age_for(scheduled_publication)
    seconds_away = scheduled_publication - Time.zone.now
    if seconds_away > cache_max_age
      cache_max_age
    elsif seconds_away >= 1
      seconds_away
    elsif seconds_away >= -30
      # If publication was due less than 30 seconds ago then it's likely the scheduled
      # publisher is working correctly.  Setting max-age to 1 second will help a little
      # with load, whilst still ensuring the document appears as soon as its published
      1.second
    else
      # If more than 30 seconds has elapsed since publication was due, then something
      # may have gone wrong.  Increase the max-age to 1 minute, so that the majority
      # of requests will still hit the cache, yet when the publication issue has been
      # resolved it will only be 1 minute before it appears.
      1.minute
    end
  end
end
