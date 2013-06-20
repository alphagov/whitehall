Given /^there are previous prime ministers$/ do
  pm_role = create(:role, name: 'Prime Minister', slug: 'prime-minister', supports_historical_accounts: true)
  previous_pm1  = create(:ministerial_role_appointment, role: pm_role, started_at: 8.years.ago, ended_at: 4.years.ago)
  previous_pm2  = create(:ministerial_role_appointment, role: pm_role, started_at: 4.years.ago, ended_at: 1.day.ago)
  current_pm    = create(:ministerial_role_appointment, role: pm_role, started_at: Time.zone.now)
  pm1_historic_account = create(:historical_account, roles: [pm_role], person: previous_pm1.person)
  pm2_historic_account = create(:historical_account, roles: [pm_role], person: previous_pm2.person)
  nineteenth_century_pm = create(:ministerial_role_appointment, role: pm_role, started_at: DateTime.civil(1801), ended_at: DateTime.civil(1804))
  eighteenth_century_pm1 = create(:ministerial_role_appointment, role: pm_role, started_at: DateTime.civil(1701), ended_at: DateTime.civil(1704))
  eighteenth_century_pm2 = create(:ministerial_role_appointment, role: pm_role, started_at: DateTime.civil(1704), ended_at: DateTime.civil(1708))

  @modern_previous_pm_appointments = [previous_pm2, previous_pm1]
  @nineteenth_century_pm_appointments = [nineteenth_century_pm]
  @eighteenth_century_pm_appointments = [eighteenth_century_pm1, eighteenth_century_pm2]
  @most_recent_appointment = previous_pm2
end

When /^I view the past prime ministers page$/ do
  visit historic_appointments_path('past-prime-ministers')
end

Then /^I should see the previous prime ministers listed according the century in which they served$/ do
  within '#modern-appointments' do
    @modern_previous_pm_appointments.each do |appointment|
      within record_css_selector(appointment) do
        assert has_css?("img[alt='#{appointment.person.name}']")
        assert has_link?(appointment.person.name)
      end
    end
  end

  within '#nineteenth-century-appointments' do
    @nineteenth_century_pm_appointments.each do |appointment|
      within record_css_selector(appointment) do
        assert has_css?("img[alt='#{appointment.person.name}']")
        assert has_content?(appointment.person.name)
      end
    end
  end

  within '#eighteenth-century-appointments' do
    @eighteenth_century_pm_appointments.each do |appointment|
      within record_css_selector(appointment) do
        assert has_css?("img[alt='#{appointment.person.name}']")
        assert has_content?(appointment.person.name)
      end
    end
  end
end

When /^I view the most recent past prime minister$/ do
  within '#modern-appointments' do
    click_on @most_recent_appointment.person.name
  end
end

Then /^I should see the most recent past priminister's historical account on the page$/ do
  assert has_content?(@most_recent_appointment.historical_account.summary)
  assert has_content?(@most_recent_appointment.historical_account.body)
end