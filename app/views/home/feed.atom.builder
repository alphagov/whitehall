atom_feed language: 'en-GB', url: atom_feed_url(format: :atom), root_url: root_url do |feed|
  feed.title 'Inside Government'
  feed.author do |author|
    author.name 'HM Government'
  end

  documents_as_feed_entries(@recently_updated, feed)
end
