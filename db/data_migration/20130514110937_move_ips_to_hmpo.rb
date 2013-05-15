ips = Organisation.find_by_slug('identity-and-passport-service')

if ips
  ips.slug = 'hm-passport-office'
  ips.save!
  puts "Updated slug for IPS"
end
