atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title [@organisation.name, 'Activity on GOV.UK'].join(' - ')
  feed.author do |author|
    author.name 'HM Government'
  end

  documents_as_feed_entries(@documents, feed)
end
