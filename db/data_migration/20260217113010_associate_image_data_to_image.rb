Image.all.pluck(:id, :image_data_id).each do |id, image_data_id|
  ImageData.find(image_data_id).update(image_id: id)
end
