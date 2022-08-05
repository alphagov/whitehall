When(/^I visit the history page$/) do
  visit admin_edition_path(@edition)
  click_link "History"
end

Then(/^I should be able to see the document's history$/) do
  ensure_path history_admin_edition_path(@edition)
  expect(find("h1").text).to eq "History"
  expect(all(".action")[0].text).to eq "Created"
end
