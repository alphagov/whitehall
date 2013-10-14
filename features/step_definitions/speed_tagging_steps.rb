When /^I go to speed tag a newly imported (publication|speech|news article|consultation|statistical data set)(?: "(.*?)")?(?: for "(.*?)"(?: and "(.*?)")?)?$/ do |edition_type, title, organisation1_name, organisation2_name|
  organisations = []
  organisations << find_or_create_organisation(organisation1_name) if organisation1_name
  organisations << find_or_create_organisation(organisation2_name) if organisation2_name
  @edition = create("imported_#{edition_type.gsub(' ', '_')}", organisations: organisations, title: title || "default title")
  visit admin_edition_path(@edition)
end

Then /^I should have to select the publication sub\-type$/ do
  assert page.has_css?("select[id*=edition_publication_type_id]")
end
Then /^I should be able to edit the text content$/ do
  assert page.has_css?("edition[title]")
  assert page.has_css?("edition[summary]")
  assert page.has_css?("edition[body]")
end

Then /^I should have to select the news article sub\-type$/ do
  assert page.has_css?("select[id*=edition_news_article_type_id]")
end

Then /^I should have to select the speech type$/ do
  assert page.has_css?("select[id*=edition_speech_type_id]")
end

Then /^I should have to select the deliverer of the speech$/ do
  assert page.has_css?("select[id*=edition_role_appointment_id]")
end

When /^I should be able to tag the (?:publication|news article) with "([^"]*)"$/ do |label|
  assert page.has_css?("label.checkbox", text: /#{label}/)
end

When /^I should not be able to tag the (?:publication|news article) with "([^"]*)"$/ do |label|
  refute page.has_css?("label.checkbox", text: /#{label}/)
end

Then /^I should be able to select the world location "([^"]*)"$/ do |name|
  select name, from: 'edition_world_location_ids'
end

When /^I can only tag the (?:publication|news article) with "([^"]*)" once$/ do |label|
  assert page.has_css?("label.checkbox", text: /#{label}/, count: 1)
end

Then /^I should be able to select the first group for the document collection "([^"]*)"$/ do |name|
  group = @document_collection.groups.first
  select "#{name} (#{group.heading})", from: 'Document collection'
end

Then /^I should be able to set the first published date$/ do
  assert page.has_css?("select[id*=edition_first_published_at_1i]")
  select_datetime '14-Dec-2011 10:30', from: "First published *"
end

Then /^I should be able to set the delivered date of the speech$/ do
  assert page.has_css?("select[id*=edition_delivered_on_1i]")
  select_date '02-May-2013', from: "Delivered on"
end

Then /^I should be able to set the consultation dates$/ do
  assert page.has_css?('select[id*=edition_opening_on]')
  assert page.has_css?('select[id*=edition_closing_on]')
end

Then /^I can choose "([^"]*)" from an additional list of policies$/ do |policy_name|
  select policy_name, from: "Additional policies"
end

Then /^I can't select "([^"]*)" from the additional list$/ do |policy_name|
  assert page.has_no_css?('option', text: policy_name)
end
