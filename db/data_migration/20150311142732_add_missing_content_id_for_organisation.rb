Organisation.where(content_id: nil).each do |organisation|
  organisation.content_id = SecureRandom.uuid
  organisation.save!(validate: false)
  puts "Setting content_id for #{organisation.name}"
end
