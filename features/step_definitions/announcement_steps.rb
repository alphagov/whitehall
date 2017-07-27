Given /^I can navigate to the list of announcements$/ do
  # 'visit homepage' means visiting the organisation homepage, because the
  # homepage is not part of this application
  stub_organisation_homepage_in_content_store
end

When /^I visit the list of announcements$/ do
  stub_content_item_from_content_store_for(announcements_path)
  visit homepage
  click_link "Announcements"
end
