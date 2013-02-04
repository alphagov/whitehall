atom_feed language: 'en-GB', root_url: activity_policy_url(@policy.document) do |feed|
  feed.title "Latest activity on \"#{@policy.title}\""
  feed.subtitle 'Recently associated'
  feed.author do |author|
    author.name 'HM Government'
  end

  documents_as_feed_entries(@recently_changed_documents.limit(10), feed)
end
