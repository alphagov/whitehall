class WorldLocationNewsPageWorker
  attr_accessor :world_location

  def perform(world_location)
    @world_location = world_location
    send_news_page_to_publishing_api
    send_news_page_to_rummager
  end

private

  def news_page_presenter
    @news_page_presenter ||= PublishingApi::WorldLocationNewsPagePresenter.new(world_location)
  end

  def send_news_page_to_publishing_api
    Services.publishing_api.put_content(news_page_presenter.content_id, news_page_presenter.content)
    Services.publishing_api.publish(news_page_presenter.content_id, news_page_presenter.update_type, locale: "en")
  end

  def send_news_page_to_rummager
    index = Whitehall::SearchIndex.for(:government)
    index.add(news_page_presenter.content_for_rummager)
  end
end
