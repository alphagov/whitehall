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
    return if lead_image.present? || images.blank?

    edition_lead_image = build_edition_lead_image(image: oldest_image)
    edition_lead_image.save!
  end

private

  def oldest_image
    images.order(:created_at, :id).first
  end
end
