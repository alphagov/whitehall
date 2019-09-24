atom_feed language: "en-GB", root_url: root_url do |feed|
  feed.title "Statistics on GOV.UK"
  feed.author do |author|
    author.name "HM Government"
  end

  documents_as_feed_entries(@statistics, feed)
end
