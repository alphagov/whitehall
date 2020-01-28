When(/^I create a fatality notice titled "([^"]*)" in the field "([^"]*)"$/) do |title, field|
  links = {
    "links" => {
      "taxons" => ["a-taxon-content-id"]
    }
  }
  Services.publishing_api.stubs(:get_links).returns(links)

  draft_fatality_notice(title, field)
  publish(force: true)
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

  assert_text notice.operational_field.description
end

Then(/^I can see the roll call introduction of the fatality notice titled "([^"]*)"$/) do |title|
  notice = FatalityNotice.find_by(title: title)

  assert_text notice.roll_call_introduction
  assert_no_text notice.summary
end

Then(/^I can create a fatality notice$/) do
  draft_fatality_notice("Fatality Notice", "Iraq")
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
    assert_text FatalityNotice.last.title, count: 1
  end
end
