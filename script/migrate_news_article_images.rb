NewsArticle.where("carrierwave_image IS NOT NULL").each do |article|
  next if article.images.any?
  begin
    puts "Retrieving image for NewsArticle##{article.id}"
    article.image.cache_stored_file!
    path_to_image = article.image.send(:cache_path)
    image = article.images.build(alt_text: article.image_alt_text, caption: article.image_caption, image_data_attributes: {file: File.open(path_to_image)})
    image.save(validate: false)
  rescue => e
    puts "issue with NewsArticle ##{article.id}"
    puts e
  end
end