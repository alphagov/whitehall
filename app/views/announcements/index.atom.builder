atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title 'Inside Government'
  feed.subtitle 'Recent announcements'
  feed.author do |author|
    author.name 'HM Government'
  end

  documents_as_feed_entries(@announcements, feed)
end
