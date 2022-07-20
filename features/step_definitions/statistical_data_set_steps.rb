When(/^I draft a new statistical data set "([^"]*)" for organisation "([^"]*)"$/) do |title, organisation_name|
  begin_drafting_statistical_data_set(title: title)
  set_lead_organisation_on_document(Organisation.find_by(name: organisation_name))
  click_button "Save and continue"
  click_button "Save and review specialist topic tagging"
  click_button "Save"
end
