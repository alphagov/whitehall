When(/^I draft a new statistical data set "([^"]*)" for organisation "([^"]*)"$/) do |title, organisation_name|
  begin_drafting_statistical_data_set(title: title)
  set_lead_organisation_on_document(Organisation.find_by(name: organisation_name))
  click_button "Next"
  select "Policy 1", from: "Policies"
  click_button "Save legacy associations"
end
