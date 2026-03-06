Given(/^I'm administering a topical event$/) do
  event = create(:topical_event, name: "Name of event")
  stub_topical_event_in_content_store("Name of event")
  visit admin_topical_event_path(event)
end

When(/^I add a page of information about the event$/) do
  click_link "About page"
  click_link "Create new about page"
  fill_in "Name", with: "Page about the event"
  fill_in "Read more link text", with: "Read more about this event"
  fill_in "Summary", with: "Summary"
  fill_in "Body", with: "Body"
  click_button "Save"
end

Then(/^I should be able to edit the event's about page$/) do
  click_link "Edit"
  fill_in "Name", with: "About the event"
  click_button "Save"
end

Then(/^I should see the about page is updated$/) do
  expect(page).to have_text("About page saved")
end
