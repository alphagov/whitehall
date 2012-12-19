atom_feed language: 'en-GB', root_url: topic_url(@topic) do |feed|
  feed.title "Latest activity on \"#{@topic.name}\""
  feed.author do |author|
    author.name 'HM Government'
  end

  govdelivery_version = feed_wants_govdelivery_version?
  documents_as_feed_entries(@recently_changed_documents, feed, govdelivery_version, @topic.created_at)
end
