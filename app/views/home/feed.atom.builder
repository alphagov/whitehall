atom_feed language: 'en-GB', url: atom_feed_url(format: :atom), root_url: root_url do |feed|
  feed.title 'Inside government'
  feed.subtitle 'Recently updated'
  feed.author do |author|
    author.name 'HM Government'
  end
  feed.updated @recently_updated.first.timestamp_for_sorting

  @recently_updated.each do |document|
    feed.entry(document, url: public_document_url(document), published: document.timestamp_for_sorting, updated: document.published_at) do |entry|
      entry.title document.title
      entry.content govspeak_edition_to_html(document), type: 'html'
    end
  end
end
