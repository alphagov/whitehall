gone_worker = PublishingApiGoneWorker.new
url_maker = Whitehall::UrlMaker.new

edition_locales_no_longer_available = {
  462010 => :ur,
  469420 => :es,
  511083 => :sq,
  522054 => :cy,
  681937 => :es,
}

edition_locales_no_longer_available.each do |edition_id, locale|
  edition = Edition.find(edition_id)

  alternative_url = url_maker.public_document_url(edition)
  explanation = 'This translation is no longer available. You can find ' +
    'the original version of this content at ' +
    "[#{alternative_url}](#{alternative_url})"

  gone_worker.perform(edition.content_id, nil, explanation, locale)
end
