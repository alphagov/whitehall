Given /^I can navigate to the list of announcements$/ do
  # 'visit homepage' means visiting the organisation homepage, because the
  # homepage is not part of this application
  stub_organisation_homepage_in_content_store
end

When /^I visit the list of announcements$/ do
  visit homepage
  click_link "Announcements"
end
