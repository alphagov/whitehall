When(/^I continue to the tagging page$/) do
  click_button "Save and go to document summary"
  click_link "Add tags"
end

When(/^I continue to the legacy tagging page$/) do
  click_button "Update and review specialist topic tags"
end
