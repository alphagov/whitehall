atom_feed language: 'en-GB', root_url: root_url do |feed|
  feed.title 'Inside Government'
  feed.subtitle 'Recent announcements'
  feed.author do |author|
    author.name 'HM Government'
  end
  feed.updated(@announcements.any? ? @announcements.first.display_date : Time.zone.now)

  @announcements.each do |document|
    feed.entry(document, url: public_document_url(document), published: document.display_date, updated: document.display_date) do |entry|
      entry.title document.title
      entry.content govspeak_edition_to_html(document), type: 'html'
    end
  end
end
