Given(/^the topical event has an offsite link with the title "([^"]*)"$/) do |title|
  create(:offsite_link, parent_type: "TopicalEvent", parent: @topical_event, title:)
end

Given(/^the topical event standard edition has an offsite link with the title "([^"]*)"$/) do |title|
  create(:offsite_link, parent: @topical_event, title:)
end

When(/^I visit the topical event featuring index page$/) do
  visit admin_topical_event_topical_event_featurings_path(@topical_event)
end

When(/^I visit the standard edition featuring index page$/) do
  visit features_admin_standard_edition_path(@topical_event)
end

Given(/^the topical event has an edition with the title "([^"]*)"$/) do |title|
  edition = create(:publication, :published, title:)
  create(:topical_event_membership, edition:, topical_event: @topical_event)
end

Given(/^the topical event standard edition is linked to an edition with the title "([^"]*)"$/) do |title|
  create(:publication, :published, title:, topical_event_documents: [@topical_event.document])
end

And(/^two featurings exist for "([^"]*)"$/) do |name|
  topical_event = TopicalEvent.find_by(name:)
  offsite_link1 = create(:offsite_link, parent_type: "TopicalEvent", parent: topical_event, title: "Featured link 1")
  offsite_link2 = create(:offsite_link, parent_type: "TopicalEvent", parent: topical_event, title: "Featured link 2")
  create(:offsite_topical_event_featuring, topical_event:, offsite_link: offsite_link1)
  create(:offsite_topical_event_featuring, topical_event:, offsite_link: offsite_link2)
end

And(/^two featurings exist for the edition$/) do
  offsite_link1 = create(:offsite_link, parent: @topical_event, title: "Featured link 1")
  offsite_link2 = create(:offsite_link, parent: @topical_event, title: "Featured link 2")
  feature_list = @topical_event.feature_lists.create!(locale: @topical_event.primary_locale)
  create(:feature, feature_list:, offsite_link: offsite_link1)
  create(:feature, feature_list:, offsite_link: offsite_link2)
end

And(/^I set the order of the topical event featurings to:$/) do |featurings_order|
  click_link "Reorder documents"

  featurings_order.hashes.each do |hash|
    featuring = @topical_event.topical_event_featurings.select { |f| f.title == hash[:title] }.first
    fill_in "topical_event_featurings[ordering][#{featuring.id}]", with: hash[:order]
  end

  click_button "Update order"
end

And(/^I set the order of the edition featurings to:$/) do |featurings_order|
  click_link "Reorder documents"

  featurings_order.hashes.each do |hash|
    featuring = @topical_event.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    fill_in "ordering[#{featuring.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the topical event featurings should be in the following order:$/) do |featurings_titles|
  featuring_titles = all("table td:first").map(&:text)

  featurings_titles.hashes.each_with_index do |hash, index|
    featuring = @topical_event.topical_event_featurings.select { |f| f.title == hash[:title] }.first
    expect(featuring.title).to eq(featuring_titles[index])
  end
end

Then(/^the edition featurings should be in the following order:$/) do |featurings_titles|
  featuring_titles = all("table td:first").map(&:text)

  featurings_titles.hashes.each_with_index do |hash, index|
    featuring = @topical_event.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    expect(featuring.to_s).to eq(featuring_titles[index])
  end
end
