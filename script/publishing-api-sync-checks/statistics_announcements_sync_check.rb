statistics_announcements = StatisticsAnnouncement.unscoped.includes(:publication).all
check = DataHygiene::PublishingApiSyncCheck.new(statistics_announcements)

def has_been_redirected?(statistics_announcement)
  publication_published?(statistics_announcement) || statistics_announcement.unpublished?
end

def publication_published?(statistics_announcement)
  statistics_announcement.publication && statistics_announcement.publication.published?
end

check.add_expectation("base_path") do |content_store_payload, model|
  content_store_payload["base_path"] == model.public_path
end

check.add_expectation("format") do |content_store_payload, model|
  content_store_payload["format"] == if has_been_redirected?(model)
                                       "redirect"
                                     else
                                       "statistics_announcement"
                                     end
end

check.add_expectation("title") do |content_store_payload, model|
  if has_been_redirected?(model)
    #announcements that relate to published statistics have 'null' title
    #so we can ignore
    true
  else
    content_store_payload["title"] == model.title
  end
end

check.perform
