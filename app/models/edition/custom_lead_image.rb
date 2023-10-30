module Edition::CustomLeadImage
  extend ActiveSupport::Concern

  included do
    validate :body_does_not_contain_lead_image_markdown
  end

  def update_lead_image
    if %w[no_image organisation_image].include?(image_display_option)
      remove_lead_image
      return
    end

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

  def body_does_not_contain_lead_image_markdown
    return if lead_image.blank?

    if body_contains_lead_image_filename_markdown? || body_contains_lead_image_index_markdown?
      errors.add(:body, "cannot have a reference to the lead image in the text")
    end
  end

  def body_contains_lead_image_filename_markdown?
    body.match?(/\[Image:\s*#{Regexp.escape(lead_image.filename)}\s*\]/)
  end

  def body_contains_lead_image_index_markdown?
    lead_image_index = images.find_index(lead_image)

    body.match?(/^!!#{lead_image_index + 1}([^\d]|$)/)
  end
end
