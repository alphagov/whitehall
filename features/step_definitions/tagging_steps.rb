When(/^I continue to the tagging page$/) do
  click_button "Save"
  click_link "Add tag"
end

When(/^I continue to the legacy tagging page$/) do
  click_button "Save"
  click_link "Add specialist topic tags"
end
