module CacheControlHelper
  def expire_on_next_scheduled_publication(scheduled_editions)
    earliest_scheduled_publication = scheduled_editions.map(&:scheduled_publication).compact.min
    max_age = max_age_for(earliest_scheduled_publication) if earliest_scheduled_publication
    expires_in(max_age, public: true) if max_age
  end

  def max_age_for(scheduled_publication)
    seconds_away = scheduled_publication - Time.zone.now
    if seconds_away > Whitehall.default_cache_max_age
      Whitehall.default_cache_max_age
    elsif seconds_away >= 1
      seconds_away
    elsif seconds_away < -600
      nil
    elsif seconds_away < -300
      30
    elsif seconds_away < -30
      5
    elsif seconds_away < 1
      1
    end
  end
end