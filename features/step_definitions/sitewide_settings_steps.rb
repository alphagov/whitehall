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
  pm_person = create(:person, forename: 'Firstname', surname: 'Lastname')
  pm_role = create(:ministerial_role_without_organisation, name: 'Prime Minister', cabinet_member: true)
  create(:ministerial_role_appointment, role: pm_role, person: pm_person)
  visit "/government/how-government-works"
end

Then(/^I should (not )?see the minister counts$/) do |negate|
  if negate
    assert_no_selector ".feature-ministers"
  else
    assert_selector ".feature-ministers"
  end
end

Then(/^I should (not )?see a reshuffle warning message$/) do |negate|
  if negate
    assert_no_text "Test minister <a rel=\"external\" href=\"http://example.com\">reshuffle</a> message"
  else
    assert_text "Test minister reshuffle message"
  end
end

Then(/^I should not see the ministers and cabinet$/) do
  assert_no_selector "h2", text: "Cabinet ministers"
  assert_no_selector "h2", text: "Also attends Cabinet"
  assert_no_selector "h2", text: "Ministers by department"
end
