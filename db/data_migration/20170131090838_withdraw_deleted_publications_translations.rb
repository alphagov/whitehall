edition_translation_data = {
  526403 => ["en", "zh", "zh-tw"],
  654995  => ["cy", "en"],
  679612  => ["cy", "en"],
  505871  => ["cy", "en"],
  474060  => ["cy", "en"],
  698000  => ["cy", "en"],
  610495  => ["cy", "en"],
  630871  => ["cy", "en"],
  665884  => ["cy", "en"],
  599695  => ["cy", "en"],
  626791  => ["cy", "en"],
  440210  => ["cy", "en"],
  571531  => ["cy", "en"],
  537197  => ["cy", "en"],
  533156  => ["cy", "en"],
  545235  => ["cy", "en"],
  641072  => ["cy", "en"],
  647249  => ["en", "ja", "ko", "zh"],
}

edition_translation_data.each do |edition_id, locales|
  edition = Edition.find_by(id: edition_id)
  if edition
    edition_translation_locales = edition.translations.map(&:locale).map(&:to_s)
    locales.each do |locale|
      unless edition_translation_locales.include?(locale)
        alternative_url = Whitehall::UrlMaker.new.public_document_url(edition)
        explanation = "This translation is no longer available. You can find the original version of this content at [#{alternative_url}](#{alternative_url})"
        PublishingApiGoneWorker(edition.content_id, nil, explanation, locale, true)
      end
    end
  end
end
