atom_feed language: 'en-GB', root_url: activity_policy_url(@policy.document) do |feed|
  feed.title "Latest activity on \"#{@policy.title}\""
  feed.subtitle 'Recently associated'
  feed.author do |author|
    author.name 'HM Government'
  end
  feed.updated @recently_changed_documents.first.published_at

  @recently_changed_documents.each do |document|
    feed.entry(document, url: public_document_url(document), published: document.first_published_at, updated: document.published_at) do |entry|
      entry.title document.title
      entry.category human_friendly_edition_type(document)
      entry.content govspeak_edition_to_html(document), type: 'html'
    end
  end
end
