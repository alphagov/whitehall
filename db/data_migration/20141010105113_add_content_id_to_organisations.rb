Organisation.where(content_id: nil).each do |org|
  org.content_id = SecureRandom.uuid
  if org.save
    puts "Added content_id to #{org.name}"
  else
    puts "Couldn't save #{org.name} because #{org.errors.full_messages}"
  end
end
