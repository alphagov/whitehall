Given /^a social media service "([^"]*)"$/ do |name|
  create(:social_media_service, name: name)
end
