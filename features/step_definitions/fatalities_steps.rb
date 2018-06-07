When(/^I create a fatality notice titled "([^"]*)" in the field "([^"]*)" associated with "([^"]*)"$/) do |title, field, policy|
  draft_fatality_notice(title, field, policy)
  publish(force: true)
end

Then(/^the fatality notice is shown on the Announcements page$/) do
  stub_content_item_from_content_store_for(announcements_path)
  visit homepage
  click_link "Announcements"
  assert page.has_content?(FatalityNotice.last.title)
end

Given(/^there is a fatality notice titled "([^"]*)" in the field "([^"]*)"$/) do |title, field_name|
  field = create(:operational_field, name: field_name)
  create(:published_fatality_notice, title: title, operational_field: field)
end

When(/^I link the minister "([^"]*)" to the fatality notice$/) do |minister_name|
  @person = find_or_create_person(minister_name)
  create(:ministerial_role_appointment, person: @person)
  begin_new_draft_document FatalityNotice.last.title
  select minister_name, from: "Ministers"
  choose "edition_minor_change_true"
  click_button "Save"
  publish(force: true)
end

Then(/^I can view the field of operations information from a link in the metadata$/) do
  notice = FatalityNotice.last
  first(:link, notice.operational_field.name).click

  assert page.has_content?(notice.operational_field.description)
end

Then(/^I can see the roll call introduction of the fatality notice titled "([^"]*)"$/) do |title|
  notice = FatalityNotice.find_by(title: title)

  assert page.has_content?(notice.roll_call_introduction)
  assert !page.has_content?(notice.summary)
end

Then(/^I can create a fatality notice$/) do
  draft_fatality_notice("Fatality Notice", "Iraq", "Defence Policy")
end

When(/^I add a casualty to the fatality notice$/) do
  begin_new_draft_document FatalityNotice.last.title
  fill_in "Personal details", with: "Causualty"
  choose "edition_minor_change_true"
  click_button "Save"
end

Then(/^I should see a casualty listed on the field of operation page for "(.*?)"$/) do |field|
  visit operational_field_path(OperationalField.find_by(name: field))

  within '.fatality_notice ul.casualties' do
    assert page.has_content?(FatalityNotice.last.title, count: 1)
  end
end
