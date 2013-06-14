When /^I create a fatality notice titled "([^"]*)" in the field "([^"]*)"$/ do |title, field|
  draft_fatality_notice(title, field)
  publish force: true
end

Then /^the fatality notice should be visible on the public site$/ do
  visit homepage
  click_link "Announcements"
  assert page.has_content?(FatalityNotice.last.title)
end

Then /^the document should be clearly marked as a fatality notice$/ do
  click_link FatalityNotice.last.title
  assert page.has_css?(".type", text: /Operations/)
end

Then /^the document should show the field of operation as "([^"]*)"$/ do |field|
  assert page.has_css?("dt", text: "Field of operation:")
  assert page.has_css?("dd", text: field)
end

Given /^there is a fatality notice titled "([^"]*)" in the field "([^"]*)"$/ do |title, field_name|
  field = create(:operational_field, name: field_name)
  create(:published_fatality_notice, title: title, operational_field: field)
end

When /^I link the minister "([^"]*)" to the fatality notice$/ do |minister_name|
  @person = find_or_create_person(minister_name)
  create(:ministerial_role_appointment, person: @person)
  begin_new_draft_document FatalityNotice.last.title
  select minister_name, from: "Ministers"
  check "edition_minor_change"
  click_button "Save"
  publish force: true
end

Then /^I should see the minister's name listed at the top$/ do
  visit document_path(FatalityNotice.last)
  assert page.has_css?("dt", text: "Minister:")
  assert page.has_css?("dd", text: %r{#{@person.name}})
end

When /^I look at the fatality notice titled "([^"]*)"$/ do |title|
  visit document_path(FatalityNotice.find_by_title(title))
end

Then /^I can view the field of operations information from a link in the metadata$/ do
  notice = FatalityNotice.last
  click_link notice.operational_field.name

  assert page.has_content?(notice.operational_field.description)
end

Then /^I can see the roll call introduction of the fatality notice titled "([^"]*)"$/ do |title|
  notice = FatalityNotice.find_by_title(title)

  assert page.has_content?(notice.roll_call_introduction)
  assert !page.has_content?(notice.summary)
end

Then /^I can create a fatality notice$/ do
  draft_fatality_notice("Fatality Notice", "Iraq")
end
