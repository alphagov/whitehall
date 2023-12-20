edition_lead_images = EditionLeadImage.joins(image: :image_data).where("carrierwave_image LIKE '%.svg'")

edition_lead_images.each do |edition_lead_image|
  edition = edition_lead_image.edition
  edition_lead_image.destroy!
  edition.update_lead_image
end
