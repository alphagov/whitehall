Then("I should see the created event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Email address created")
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

Then(/^I should see ([^"]*) publish events on the timeline$/) do |count|
  expect(page).to have_selector(".timeline__title", text: "Email address published", count:)
end

Then("I should see the publish event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Email address published")
  expect(page).to have_selector(".timeline__byline", text: "by Scheduled Publishing Robot")
end

Then("I should see the scheduled event on the timeline") do
  expect(page).to have_selector(".timeline__title", text: "Email address scheduled")
  expect(page).to have_selector(".timeline__byline", text: "by #{@user.name}")
end

And("I should see the edition diff in a table") do
  expect(page).to have_selector(".govuk-table__cell", text: "Changed title")
  expect(page).to have_selector(".govuk-table__cell", text: @content_block.document.title)
end
