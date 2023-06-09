And(/^the topical event has a (lead|supporting) organisation called "([^"]*)"$/) do |organisation_type, name|
  organisation = create(:organisation, name:)
  @topical_event_organisation = create(:topical_event_organisation, organisation:, topical_event: @topical_event, lead: organisation_type == "lead")
end

When(/^I visit the topical event organisations index page$/) do
  visit admin_topical_event_topical_event_organisations_path(@topical_event)
end

Then(/^I can see the (lead|supporting) organisation with the name "([^"]*)"$/) do |organisation_type, name|
  within "##{organisation_type}_organisations" do
    expect(find("table th:first").text).to eq name
  end
end
