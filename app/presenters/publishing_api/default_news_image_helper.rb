module PublishingApi::DefaultNewsImageHelper
  def default_news_image
    return unless item.default_news_image && item.default_news_image.all_asset_variants_uploaded?

    {
      url: default_news_image_url(:s300),
      high_resolution_url: default_news_image_url(:s960),
    }
  end

  def default_news_image_url(size = nil)
    size ? item.default_news_image.url(size) : item.default_news_image.url
  end
end
