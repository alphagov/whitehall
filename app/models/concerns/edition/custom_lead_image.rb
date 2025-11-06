module Edition::CustomLeadImage
  extend ActiveSupport::Concern
  include GovspeakHelper

  included do
    validate :body_does_not_contain_lead_image
  end

  def update_lead_image
    if %w[no_image organisation_image].include?(image_display_option)
      remove_lead_image
      return
    end

    return if lead_image.present? || images.blank?

    image = oldest_image_that_can_be_lead_image

    if image
      edition_lead_image = build_edition_lead_image(image:)
      edition_lead_image.save!
    end
  end

  def non_lead_images
    images - [lead_image].compact
  end

private

  def oldest_image_that_can_be_lead_image
    images.includes(:image_data).detect { |image| !image.svg? && !image.requires_crop? }
  end

  def remove_lead_image
    return if edition_lead_image.blank?

    edition_lead_image.destroy!
  end

  def body_does_not_contain_lead_image
    return if edition_lead_image.blank? || images.none?

    html = govspeak_edition_to_html(self)
    doc = Nokogiri::HTML::DocumentFragment.parse(html)

    if doc.css("img[src*='#{edition_lead_image.image.filename}']").present?
      errors.add(:body, "cannot have a reference to the lead image in the text")
    end
  end
end
