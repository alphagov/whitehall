atom_feed language: 'en-GB', url: atom_feed_url(format: :atom), root_url: root_url do |feed|
  feed.title 'Inside government'
  feed.subtitle 'Recently updated'
  feed.author do |author|
    author.name 'HM Government'
  end

  if @recently_updated.any?
    feed.updated @recently_updated.first.timestamp_for_sorting
  else
    feed.updated Time.now
  end

  govdelivery_version = feed_wants_govdelivery_version?
  documents_as_feed_entries(@recently_updated, feed, govdelivery_version)
end
