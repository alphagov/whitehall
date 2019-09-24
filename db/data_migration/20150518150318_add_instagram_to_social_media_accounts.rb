# Creating an Instagram option for the SocialMediaService.

instagram = SocialMediaService.create!(name: "Instagram")

# Previously Instagram accounts were listed under other as they didn't have
# it as an option. The lines below update the existing ones.

SocialMediaAccount.where(title: "Instagram").each do |s|
  puts "Changing #{s.url}"
  s.social_media_service = instagram
  s.save!
end
