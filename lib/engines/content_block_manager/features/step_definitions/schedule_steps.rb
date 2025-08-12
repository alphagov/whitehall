require_relative "../support/helpers"

Then("I see the errors prompting me to provide a date and time") do
  assert_text "Scheduled publication date and time cannot be blank", minimum: 2
end

Then("I see the errors informing me the date is invalid") do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication.time.blank"), minimum: 2
end

Then("I should see an error message telling me that schedule publishing cannot be blank") do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.schedule_publishing.blank"), minimum: 2
end

Then("I see the errors informing me the date must be in the future") do
  assert_text I18n.t("activerecord.errors.models.content_block_manager/content_block/edition.attributes.scheduled_publication.future_date"), minimum: 2
end

When("I choose to schedule the change") do
  choose "Schedule the edit for the future"
end

And(/^I schedule the change for (\d+) days in the future$/) do |number_of_days|
  schedule_change(number_of_days)
end

And("the block is scheduled and published") do
  @is_scheduled = true
  create(:scheduled_publishing_robot)
  near_future_date = 1.minute.from_now
  fill_in_date_and_time_field(near_future_date)

  Sidekiq::Testing.inline! do
    click_on "Save and continue"
  end
end

When("I click to edit the schedule") do
  find("a", text: "Edit schedule").click
end

When("I enter an invalid date") do
  fill_in "Year", with: "01"
end

When("I enter a date in the past") do
  past_date = 7.days.before(Time.zone.now).to_date
  fill_in_date_and_time_field(past_date)
end

Then("I should see a warning telling me there is a scheduled change") do
  assert_text "There is currently a change scheduled"
end

Given(/^I have scheduled a change for (\d+) days in the future$/) do |number_of_days|
  update_content_block
  add_internal_note
  add_change_note
  schedule_change(number_of_days)
  review_and_confirm
end
