When(/^I add an historical account to "([^"]*)" for his role as "([^"]*)"$/) do |person_name, role_name|
  person = find_person(person_name)
  role = Role.find_by(name: role_name)

  visit admin_person_url(person)
  click_link 'Historical accounts'
  click_on 'Add an historical account'
  select role.name, from: 'Role(s)'
  fill_in 'Summary', with: 'The one and only Walrus of Love'
  fill_in 'Body', with: 'Making you quiver with his dulset bass tones.'
  select 'Labour', from: 'Political parties'
  fill_in 'Major acts', with: 'Helped make lots of babies'
  fill_in 'Interesting facts', with: 'In his teenage years, he was jailed for stealing $30k worth of Cadillac tires.'
  click_on 'Save'
end

Then(/^I should see a historical account for him in that role$/) do
  historical_account = @person.historical_accounts.last
  within record_css_selector(historical_account) do
    assert page.has_content?(historical_account.summary)
    assert page.has_content?(@role.name)
  end
end
