affected_images = Image.where(image_data_id: nil)
puts "Deleting #{affected_images.count} image records with no image data. The following editions will start working again:"

affected_images.each do |image|
  puts "https://whitehall-admin.production.alphagov.co.uk/government/admin/editions/#{image.edition_id}"
end

affected_images.delete_all
puts "Done."
