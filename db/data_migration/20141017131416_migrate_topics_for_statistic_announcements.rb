puts "populating statistics announcement topics join model"

StatisticsAnnouncement.find_each do |statistics_announcement|
  print "."
  statistics_announcement.topic_ids = [statistics_announcement.topic_id]
end
