edition_translation_data = {
  526_403 => %w[en zh zh-tw],
  654_995 => %w[cy en],
  679_612 => %w[cy en],
  505_871 => %w[cy en],
  474_060 => %w[cy en],
  698_000 => %w[cy en],
  610_495 => %w[cy en],
  630_871 => %w[cy en],
  665_884 => %w[cy en],
  599_695 => %w[cy en],
  626_791 => %w[cy en],
  440_210 => %w[cy en],
  571_531 => %w[cy en],
  537_197 => %w[cy en],
  533_156 => %w[cy en],
  545_235 => %w[cy en],
  641_072 => %w[cy en],
  647_249 => %w[en ja ko zh],
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
