Given(/^we are (not )?during a reshuffle$/) do |negate|
  unless negate
    minister_reshuffle = SitewideSetting.new(
      key: :minister_reshuffle_mode,
      on: true,
      govspeak: "Test minister [reshuffle](http://example.com) message"
    )
    minister_reshuffle.save!
  end
end

When(/^I visit the How Government Works page$/) do
  visit "/government/how-government-works"
end

Then(/^I should (not )?see the minister counts$/) do |negate|
  if negate
    assert page.has_no_css?(".feature-ministers")
  else
    assert page.has_css?(".feature-ministers")
  end
end

Then(/^I should (not )?see a reshuffle warning message$/) do |negate|
  if negate
    assert page.has_no_content?("Test minister <a rel=\"external\" href=\"http://example.com\">reshuffle</a> message")
  else
    assert page.has_content?("Test minister reshuffle message")
  end
end
