When /^I draft a new consultation response "([^"]*)" to the consultation "([^"]*)"$/ do |response_title, consultation_title|
  consultation = Consultation.find_by_title!(consultation_title)
  visit admin_consultation_path(id: consultation.id)
  click_link "Add response"
  fill_in "Title", with: response_title
  fill_in "Body", with: "First responder"
  click_button "Save"
end
