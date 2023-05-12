Given(/^we are (not )?during a reshuffle$/) do |negate|
  unless negate
    minister_reshuffle = SitewideSetting.new(
      key: :minister_reshuffle_mode,
      on: true,
      govspeak: "Test minister [reshuffle](http://example.com) message",
    )
    minister_reshuffle.save!
  end
end

Given(/^that there no sidewide settings available to edit$/) do
  SitewideSetting.delete_all
end

When(/^I visit the sitewide settings page$/) do
  visit admin_sitewide_settings_path
end

Then(/^I should see a reshuffle warning message$/) do
  expect(page).to have_content("Test minister reshuffle message")
end

Then(/^I should not see a reshuffle warning message$/) do
  expect(page).to_not have_content("Test minister reshuffle message")
end

Then(/^I should not see the ministers and cabinet$/) do
  expect(page).to_not have_selector("h2", text: "Cabinet ministers")
  expect(page).to_not have_selector("h2", text: "Also attends Cabinet")
  expect(page).to_not have_selector("h2", text: "Ministers by department")
end

Then(/^I should see an empty status message$/) do
  expect(page).to_not have_selector("p", text: "No sitewide settings available to configure.")
end
