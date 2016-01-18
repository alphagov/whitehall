class PublishingApiComingSoonWorker < PublishingApiWorker
  def perform(edition_id, locale)
    edition = Edition.find(edition_id)

    I18n.with_locale(locale) do
      coming_soon = PublishingApiPresenters::ComingSoon.new(edition)
      send_item(coming_soon, locale)
    end
  end
end
