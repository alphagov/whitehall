['Pinterest', 'LinkedIn', 'Google Plus', 'Foursquare', 'Email', 'Other'].each do |service_name|
  print "Creating social media service: #{service_name}"
  if SocialMediaService.find_by_name(service_name)
    puts ". already exists!"
  else
    SocialMediaService.create!(name: service_name)
    puts ". Done!"
  end
end
