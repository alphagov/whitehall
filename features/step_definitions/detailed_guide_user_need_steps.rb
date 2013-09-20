When(/^I try to save the detailed guide with no user need$/) do
  click_button "Save"
end

When(/^I try to save the detailed guide with the user need: as an? "(.*?)" I need "(.*?)" so that I can "(.*?)"$/) do |user, need, goal|
  fill_in "edition_user_needs_attributes_0_user", with: user
  fill_in "edition_user_needs_attributes_0_need", with: need
  fill_in "edition_user_needs_attributes_0_goal", with: goal
  click_button "Save"
end
