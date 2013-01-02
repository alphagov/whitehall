When /^I go to speed tag a newly imported (publication|speech)(?: for "(.*?)")?$/ do |edition_type, organisation_name|
  organisations = organisation_name ? [find_or_create_organisation(organisation_name)] : []
  @edition = create(edition_type, organisations: organisations)
  visit admin_edition_path(@edition)
end

Then /^I should have to select the publication sub\-type$/ do
  assert page.has_css?("select[id*=edition_publication_type_id]")
end

Then /^I should have to select the speech type$/ do
  assert page.has_css?("select[id*=edition_speech_type_id]")
end

Then /^I should have to select the deliverer of the speech$/ do
  assert page.has_css?("select[id*=edition_role_appointment_id]")
end

When /^I should be able to tag the publication with "([^"]*)"$/ do |label|
  assert page.has_css?("label.checkbox", text: /#{label}/)
end

When /^I should not be able to tag the publication with "([^"]*)"$/ do |label|
  refute page.has_css?("label.checkbox", text: /#{label}/)
end

After { |scenario| save_and_open_page if scenario.failed? }
