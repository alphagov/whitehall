When /^I draft a new international priority "([^"]*)"$/ do |title|
  begin_drafting_document type: "international_priority", title: title
  click_button "Save"
end

Given /^a published international priority "([^"]*)" exists relating to the country "([^"]*)"$/ do |title, country_name|
  country = Country.find_by_name!(country_name)
  create(:published_international_priority, title: title, countries: [country])
end
