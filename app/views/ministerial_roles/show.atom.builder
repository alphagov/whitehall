atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title ['Inside government', @ministerial_role.name].join(" - ")
  feed.subtitle 'Latest'
  feed.author do |author|
    author.name 'HM Government'
  end
  announcements = @ministerial_role.announcements

  documents_as_feed_entries(announcements, feed)
end
