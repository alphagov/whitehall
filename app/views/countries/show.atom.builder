atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title ['Inside government', @country.name].join(" - ")
  feed.subtitle 'Latest'
  feed.author do |author|
    author.name 'HM Government'
  end
  feed.updated(@documents.any? ? @documents.first.display_date : Time.zone.now)

  @documents.each do |document|
    feed.entry(document, url: public_document_url(document), published: document.display_date, updated: document.display_date) do |entry|
      entry.title document.title
      entry.content govspeak_edition_to_html(document), type: 'html'
    end
  end
end
