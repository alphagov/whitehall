atom_feed language: 'en-GB', root_url: topic_url(@topic) do |feed|
  feed.title "Latest activity on \"#{@topic.name}\""
  feed.author do |author|
    author.name 'HM Government'
  end

  if @recently_changed_documents.any?
    feed.updated @recently_changed_documents.first.timestamp_for_sorting
  else
    feed.updated @topic.created_at
  end

  govdelivery_version = feed_wants_govdelivery_version?
  @recently_changed_documents.each do |document|
    feed.entry(document, url: public_document_url(document), published: document.timestamp_for_sorting, updated: document.published_at) do |entry|
      document_as_feed_entry(document, feed, govdelivery_version)
    end
  end
end
