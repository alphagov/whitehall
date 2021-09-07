Given(/^there are previous prime ministers$/) do
  pm_role = create(:role, name: "Prime Minister", slug: "prime-minister", supports_historical_accounts: true)
  previous_pm1 = create(:ministerial_role_appointment, role: pm_role, started_at: 8.years.ago, ended_at: 4.years.ago)
  previous_pm2 = create(:ministerial_role_appointment, role: pm_role, started_at: 4.years.ago, ended_at: 1.day.ago)
  _current_pm = create(:ministerial_role_appointment, role: pm_role, started_at: Time.zone.now)
  _pm1_historic_account = create(:historical_account, roles: [pm_role], person: previous_pm1.person)
  _pm2_historic_account = create(:historical_account, roles: [pm_role], person: previous_pm2.person)

  twentieth_century_appointments = create(:ministerial_role_appointment, role: pm_role, started_at: Date.civil(1901), ended_at: Date.civil(2000))
  eighteenth_century_pm1 = create(:ministerial_role_appointment, role: pm_role, started_at: Date.civil(1701), ended_at: Date.civil(1704))
  eighteenth_century_pm2 = create(:ministerial_role_appointment, role: pm_role, started_at: Date.civil(1704), ended_at: Date.civil(1708))

  @most_recent_appointment = previous_pm2
  @modern_previous_pm_appointments = [previous_pm2, previous_pm1]
  @twentieth_century_appointments_appointments = [twentieth_century_appointments]
  @eighteenth_century_pm_appointments = [eighteenth_century_pm1, eighteenth_century_pm2]
end

When(/^I view the past prime ministers page$/) do
  visit historic_appointments_path("past-prime-ministers")
end

Then(/^I should see the previous prime ministers listed according the century in which they served$/) do
  # On page check 21th Century
  within ".historic-appointments-index" do
    @modern_previous_pm_appointments.each do |appointment|
      within record_css_selector(appointment) do
        expect(page).to have_link(appointment.person.name)
      end
    end
  end

  # On page check 20th century
  within ".historic-appointments-index" do
    @twentieth_century_appointments_appointments.each do |appointment|
      within record_css_selector(appointment) do
        expect(page).to have_content(appointment.person.name)
      end
    end
  end

  # On page check 18th & 19th centuries
  within ".historic-appointments-index" do
    @eighteenth_century_pm_appointments.each do |appointment|
      within record_css_selector(appointment) do
        expect(page).to have_content(appointment.person.name)
      end
    end
  end
end

When(/^I view the most recent past prime minister$/) do
  # On page check check the most recent past prime minster
  within ".historic-appointments-index" do
    find("a", text: @most_recent_appointment.person.name).click
  end
end

Then(/^I should see the most recent past priminister's historical account on the page$/) do
  expect(page).to have_content(@most_recent_appointment.historical_account.summary)
  expect(page).to have_content(@most_recent_appointment.historical_account.body)
end
