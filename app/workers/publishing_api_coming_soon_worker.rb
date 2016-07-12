class PublishingApiComingSoonWorker < PublishingApiWorker
  def call(edition_id, locale)
    edition = Edition.find(edition_id)

    I18n.with_locale(locale) do
      coming_soon = PublishingApi::ComingSoonPresenter.new(edition)
      send_item(coming_soon, locale)
    end
  end
end
