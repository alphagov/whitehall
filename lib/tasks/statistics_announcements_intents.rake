namespace :statistics_announcements do
  desc "Updates the publish intent for StatisticsAnnouncements scheduled for release in the future"
  task put_intents_for_scheduled: :environment do
    latest_join_sql = <<-SQL
      statistics_announcement_dates.created_at = (
        select max(statistics_announcement_dates.created_at)
        from statistics_announcement_dates
        where statistics_announcement_dates.statistics_announcement_id = statistics_announcements.id
      )
    SQL

    statistics_announcements = StatisticsAnnouncement
      .joins(:statistics_announcement_dates)
      .where("statistics_announcement_dates.release_date > ?", Date.current)
      .where(latest_join_sql)

    statistics_announcements.each do |statistics_announcement|
      no_update_required = statistics_announcement.unpublished? || statistics_announcement.cancelled?
      statistics_announcement.update_publish_intent unless no_update_required
    end
  end
end
