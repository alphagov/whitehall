class WorldLocationNewsPageWorker < WorkerBase
  attr_accessor :world_location

  def perform(world_location_id)
    self.world_location = WorldLocation.find(world_location_id)

    each_locale do
      send_news_page_to_publishing_api
    end

    send_news_page_to_rummager
  end

private

  def each_locale
    world_location.available_locales.each do |locale|
      I18n.with_locale(locale) { yield }
    end
  end

  def send_news_page_to_publishing_api
    Services.publishing_api.put_content(content_id, presenter.content)
    Services.publishing_api.publish(content_id, nil, locale: I18n.locale)
  end

  def presenter
    PublishingApi::WorldLocationNewsPagePresenter.new(world_location)
  end

  def send_news_page_to_rummager
    document = presenter.content_for_rummager(content_id)
    search_index.add(document)
  end

  def search_index
    Whitehall::SearchIndex.for(:government, logger: logger)
  end

  # We use the same content_id for all locales so that Publishing API knows
  # these are translations, rather than separate documents.
  def content_id
    world_location.news_page_content_id
  end
end
