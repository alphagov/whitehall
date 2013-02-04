atom_feed language: 'en-GB', root_url: classification_url(@classification) do |feed|
  feed.title "Latest activity on \"#{@classification.name}\""
  feed.author do |author|
    author.name 'HM Government'
  end

  documents_as_feed_entries(@recently_changed_documents, feed, @classification.created_at)
end
