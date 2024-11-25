class LandingPage::HeroBlock < LandingPage::BaseBlock
  include ActiveModel::API

  IMAGE_PATTERN = /^\[Image:\s*(.*?)\s*\]/
  EXPECTED_IMAGE_KINDS = {
    desktop_image: "hero_desktop",
    tablet_image: "hero_tablet",
    mobile_image: "hero_mobile",
  }.freeze

  attr_reader :desktop_image, :tablet_image, :mobile_image, :hero_content_blocks

  validates :desktop_image, :tablet_image, :mobile_image, :hero_content_blocks, presence: true
  validates_each :desktop_image, :tablet_image, :mobile_image do |record, attr, value|
    next if value.blank?

    expected_kind = EXPECTED_IMAGE_KINDS.fetch(attr)
    actual_kind = value.image_data.image_kind
    record.errors.add(attr, "is of the wrong image kind: #{actual_kind}") if actual_kind != expected_kind
  end

  def initialize(source, images)
    super
    @hero_content_blocks = LandingPage::BlockFactory.build_all(source.dig("hero_content", "blocks"), images)

    image_sources = @source.dig("image", "sources") || {}
    @desktop_image = find_image(image_sources["desktop"])
    @tablet_image = find_image(image_sources["tablet"])
    @mobile_image = find_image(image_sources["mobile"])
  end

  def present_for_publishing_api
    return { "errors" => errors.to_a } if invalid?

    @source.merge({
      "image" => {
        # NOTE: alt text is always blank for hero images, as they are decorative
        "alt" => "",
        "sources" => present_image_sources,
      },
      "hero_content" => {
        "blocks" => @hero_content_blocks.map(&:present_for_publishing_api),
      },
    })
  end

  def present_image_sources
    {
      "desktop" => desktop_image.url(:hero_desktop_1x),
      "desktop_2x" => desktop_image.url(:hero_desktop_2x),
      "tablet" => tablet_image.url(:hero_tablet_1x),
      "tablet_2x" => tablet_image.url(:hero_tablet_2x),
      "mobile" => mobile_image.url(:hero_mobile_1x),
      "mobile_2x" => mobile_image.url(:hero_mobile_2x),
    }
  end

  def find_image(image_expression)
    match = IMAGE_PATTERN.match(image_expression)
    return if match.nil?

    image_id = match.captures.first
    images.find { _1.filename == image_id }
  end
end
