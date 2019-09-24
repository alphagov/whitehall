require "securerandom"

StatisticsAnnouncement.unscoped.where(content_id: "").find_each do |statistics_announcement|
  statistics_announcement.update_column(:content_id, SecureRandom.uuid)
end
