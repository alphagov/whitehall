module Edition::CustomLeadImage
  extend ActiveSupport::Concern

  included do
    validates :body,
              format: {
                without: /^!!1([^\d]|$)/,
                message: "cannot have a reference to the first image in the text",
                multiline: true,
              }
  end

  def image_disallowed_in_body_text?(index)
    index == 1
  end

  def update_lead_image
    remove_lead_image and return if %w[no_image organisation_image].include?(image_display_option)

    return if lead_image.present? || images.blank?

    edition_lead_image = build_edition_lead_image(image: oldest_image)
    edition_lead_image.save!
  end

private

  def oldest_image
    images.order(:created_at, :id).first
  end

  def remove_lead_image
    return if edition_lead_image.blank?

    edition_lead_image.destroy!
  end
end
