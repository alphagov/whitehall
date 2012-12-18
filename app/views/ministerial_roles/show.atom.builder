atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title ['Inside government', @ministerial_role.name].join(" - ")
  feed.subtitle 'Latest'
  feed.author do |author|
    author.name 'HM Government'
  end
  announcements = @ministerial_role.announcements
  feed.updated(announcements.any? ? announcements.first.display_date : Time.zone.now)

  govdelivery_version = feed_wants_govdelivery_version?
  documents_as_feed_entries(announcements, feed, govdelivery_version)
end
