atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title 'Inside government'
  feed.subtitle 'Recent publications'
  feed.author do |author|
    author.name 'HM Government'
  end
  feed.updated(@publications.any? ? @publications.first.display_date : Time.zone.now)

  govdelivery_version = feed_wants_govdelivery_version?
  documents_as_feed_entries(@publications, feed, govdelivery_version)
end
