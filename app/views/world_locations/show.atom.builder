atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title ['Inside government', @world_location.name].join(" - ")
  feed.subtitle 'Latest'
  feed.author do |author|
    author.name 'HM Government'
  end

  govdelivery_version = feed_wants_govdelivery_version?
  documents_as_feed_entries(@documents, feed, govdelivery_version)
end
