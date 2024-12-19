class LandingPages::ImageBlock < LandingPages::BaseBlock
  include ActiveModel::API
  include LandingPageImageBlock

  def initialize(source, images)
    super(source, images)

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
