And(/^the topical event has a (lead|supporting) organisation called "([^"]*)"$/) do |organisation_type, name|
  organisation = create(:organisation, name:)
  @topical_event_organisation = create(:topical_event_organisation, organisation:, topical_event: @topical_event, lead: organisation_type == "lead")
end

When(/^I visit the topical event organisations index page$/) do
  visit admin_topical_event_topical_event_organisations_path(@topical_event)
end

Then(/^I can see the (lead|supporting) organisation with the name "([^"]*)"$/) do |organisation_type, name|
  within "##{organisation_type}_organisations" do
    organisations = all("table th").map(&:text)
    expect(organisations).to include name
  end
end

And(/^I set the order of lead organisations to:$/) do |organisations_order|
  within "#lead_organisations" do
    click_link "Reorder organisations"
  end

  organisations_order.hashes.each do |hash|
    topical_event_organisation = @topical_event.topical_event_organisations.where(lead: true).select { |f| f.organisation.name == hash[:name] }.first
    fill_in "topical_event_lead_organisations[ordering][#{topical_event_organisation.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the lead organisations should be in the following order:$/) do |expected_organisations_order|
  within "#lead_organisations" do
    actual_organisations_order = all("table th").map(&:text)

    expected_organisations_order.hashes.each_with_index do |hash, index|
      topical_event_organisation = @topical_event.topical_event_organisations.where(lead: true).select { |f| f.organisation.name == hash[:name] }.first
      expect(topical_event_organisation.organisation.name).to eq(actual_organisations_order[index])
    end
  end
end

And(/^I make "([^"]*)" a (lead|supporting) organisation$/) do |name, organisation_type|
  click_link "Make #{organisation_type} #{name}"
end

Then(/^I can see a "([^"]*)" success notice$/) do |message|
  expect(find(".govuk-notification-banner__heading").text).to eq message
end
