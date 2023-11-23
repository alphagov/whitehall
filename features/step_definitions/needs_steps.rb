When(/^I start editing the needs from the .*? page$/) do
  click_link "Modify associated user needs"
end

When(/^I choose the first need in the dropdown$/) do
  option = first("#need_ids option").text
  select option, from: "need_ids"
  click_button "Save"
end

Then(/^I should see the first need in the list of associated needs$/) do
  find("h2:contains('Associated user needs')")
  expect(first(".app-view-summary__section-user-needs .govuk-table__cell").text).to eq("As a x, I need to y, So that z")
end
