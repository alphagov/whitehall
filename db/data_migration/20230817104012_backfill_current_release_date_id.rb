count = 0
total = StatisticsAnnouncement.count
StatisticsAnnouncement.find_each do |statistics_announcement|
  latest = statistics_announcement.statistics_announcement_dates.reverse_order
  statistics_announcement.update_column(:current_release_date_id, latest.pick(:id))
  count += 1
  puts "#{count}/#{total} completed"
end
