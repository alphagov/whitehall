When(/^the sidebar scheduling feature flag is (enabled|disabled)$/) do |sidebar_scheduling_enabled|
  @test_strategy ||= Flipflop::FeatureSet.current.test!
  @test_strategy.switch!(:sidebar_scheduling, sidebar_scheduling_enabled == "enabled")
end

When(/^I propose scheduling the publication "([^"]*)" to be published in one month$/) do |publication_title|
  publication = Publication.find_by(title: publication_title)
  ensure_path(admin_edition_path(publication))
  if Flipflop.sidebar_scheduling?
    click_link "Schedule"
    fill_in_date_and_time_field 1.month.since
    click_button "Schedule"
  else
    click_link "Edit draft"
    check "Schedule for publication"
    within "#scheduled_publication_active" do
      fill_in_date_and_time_field 1.month.since
    end
    click_button "Save and go to document summary"
  end
end

When(/^another editor approves "([^"]*)" for scheduled publication$/) do |publication_title|
  user = create(:departmental_editor, name: "Other editor")
  login_as user
  publication = Publication.find_by(title: publication_title)
  visit admin_edition_path(publication)
  click_link publication_title
  click_link "Schedule"
  click_button "Schedule"
end

Then(/^the publication "([^"]*)" should have a scheduled publishing date one month in the future$/) do |publication_title|
  publication = Publication.find_by(title: publication_title)
  ensure_path(admin_edition_path(publication))
  expect(page).to have_content("Scheduled publication proposed for #{1.month.since}")
end