module Presenters::PublishingApi::DefaultNewsImageHelper
private

  def present_default_news_image(item)
    return unless item.default_news_image && item.default_news_image.all_asset_variants_uploaded?

    {
      url: default_news_image_url(item, :s300),
      high_resolution_url: default_news_image_url(item, :s960),
    }
  end

  def default_news_image_url(item, size = nil)
    size ? item.default_news_image.url(size) : item.default_news_image.url
  end
end
