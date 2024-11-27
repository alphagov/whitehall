module LandingPageImageBlock
  extend ActiveSupport::Concern

  IMAGE_PATTERN = /^\[Image:\s*(.*?)\s*\]/
  EXPECTED_IMAGE_KINDS = {
    desktop_image: "landing_page_image",
    tablet_image: "landing_page_image",
    mobile_image: "landing_page_image",
  }.freeze

  included do
    attr_reader :desktop_image, :tablet_image, :mobile_image, :alt

    validates :desktop_image, :tablet_image, :mobile_image, presence: true
    validates_each :desktop_image, :tablet_image, :mobile_image do |record, attr, value|
      next if value.blank?

      expected_kind = EXPECTED_IMAGE_KINDS.fetch(attr)
      actual_kind = value.image_data.image_kind
      record.errors.add(attr, "is of the wrong image kind: #{actual_kind}") if actual_kind != expected_kind
    end

    def present_image
      {
        "image" => {
          "alt" => alt,
          "sources" => present_image_sources,
        },
      }
    end

    def present_image_sources
      {
        "desktop" => desktop_image.url(:landing_page_desktop_1x),
        "desktop_2x" => desktop_image.url(:landing_page_desktop_2x),
        "tablet" => tablet_image.url(:landing_page_tablet_1x),
        "tablet_2x" => tablet_image.url(:landing_page_tablet_2x),
        "mobile" => mobile_image.url(:landing_page_mobile_1x),
        "mobile_2x" => mobile_image.url(:landing_page_mobile_2x),
      }
    end

    def find_image(image_expression)
      match = IMAGE_PATTERN.match(image_expression)
      return if match.nil?

      image_id = match.captures.first
      images.find { _1.filename == image_id }
    end
  end
end
