puts "Populating join table StatisticsAnnouncementOrganisations with existing associations between StatisticsAnnouncements and Organisations"
StatisticsAnnouncement.find_each do |announcement|
  StatisticsAnnouncementOrganisation.create!(
    statistics_announcement_id: announcement.id,
    organisation_id: announcement.attributes["organisation_id"],
  )
end
