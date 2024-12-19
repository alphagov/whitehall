class LandingPages::FeaturedBlock < LandingPages::CompoundBlock
  include ActiveModel::API
  include LandingPageImageBlock

  def initialize(source, images, content_blocks)
    super(source, images, "featured_content", content_blocks)

    image_sources = @source.dig("image", "sources") || {}
    @desktop_image = find_image(image_sources["desktop"])
    @tablet_image = find_image(image_sources["tablet"])
    @mobile_image = find_image(image_sources["mobile"])
    @alt = @source.dig("image", "alt") || ""
  end

  def present_for_publishing_api
    super.merge(present_image)
  end
end
