edition_translation_data = {
  526403 => ["en", "zh", "zh-tw"],
  654995  => %w[cy en],
  679612  => %w[cy en],
  505871  => %w[cy en],
  474060  => %w[cy en],
  698000  => %w[cy en],
  610495  => %w[cy en],
  630871  => %w[cy en],
  665884  => %w[cy en],
  599695  => %w[cy en],
  626791  => %w[cy en],
  440210  => %w[cy en],
  571531  => %w[cy en],
  537197  => %w[cy en],
  533156  => %w[cy en],
  545235  => %w[cy en],
  641072  => %w[cy en],
  647249  => %w[en ja ko zh],
}

edition_translation_data.each do |edition_id, locales|
  edition = Edition.find_by(id: edition_id)
  if edition
    edition_translation_locales = edition.translations.map(&:locale).map(&:to_s)
    locales.each do |locale|
      unless edition_translation_locales.include?(locale)
        alternative_url = Whitehall::UrlMaker.new.public_document_url(edition)
        explanation = "This translation is no longer available. You can find the original version of this content at [#{alternative_url}](#{alternative_url})"
        PublishingApiGoneWorker.perform_async(edition.content_id, nil, explanation, locale, true)
      end
    end
  end
end
