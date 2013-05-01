puts "Updating social media accounts: "
count = 0
SocialMediaAccount.find_each do |social_media_account|
  if (social_media_account.url.strip!)
    puts "Fixing: #{social_media_account.url}"
    social_media_account.update_column(:url, social_media_account.url)
    count += 1
  end
end
puts " #{count} accounts updated."
