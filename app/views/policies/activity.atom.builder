atom_feed language: 'en-GB', root_url: activity_policy_url(@policy.document) do |feed|
  feed.title [@policy.title, 'Activity on GOV.UK'].join(' - ')
  feed.author do |author|
    author.name 'HM Government'
  end

  documents_as_feed_entries(@recently_changed_documents.limit(10), feed)
end
