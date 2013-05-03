atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title [@person.name, 'Activity on GOV.UK'].join(' - ')
  feed.author do |author|
    author.name 'HM Government'
  end
  announcements = @person.announcements

  documents_as_feed_entries(announcements, feed)
end
