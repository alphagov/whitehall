atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title 'Inside government'
  feed.subtitle 'Recent publications'
  feed.author do |author|
    author.name 'HM Government'
  end
  feed.updated(@publications.any? ? @publications.first.published_at : Time.zone.now)

  @publications.each do |document|
    feed.entry(document, url: public_document_url(document), published: document.first_published_at, updated: document.published_at) do |entry|
      entry.title document.title
      entry.content govspeak_edition_to_html(document), type: 'html'
    end
  end
end
