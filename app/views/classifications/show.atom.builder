atom_feed language: "en-GB", root_url: classification_url(@topical_event) do |feed|
  feed.title [@topical_event.name, "Activity on GOV.UK"].join(" - ")
  feed.author do |author|
    author.name "HM Government"
  end

  documents_as_feed_entries(@recently_changed_documents, feed, @topical_event.created_at)
end
