def add_translation_to_world_location(location, translation)
  translation = translation.stringify_keys
  visit admin_world_location_news_path(location)
  click_link "Translations"

  select translation["locale"], from: "Locale"
  click_on "Create translation"
  fill_in "Name", with: translation["name"]
  fill_in "Title", with: translation["title"]
  fill_in "Mission statement", with: translation["mission_statement"]
  click_on "Save"
end

Given(/^an? (world location|international delegation) "([^"]*)" exists$/) do |world_location_type, name|
  world_location = create(world_location_type.tr(" ", "_").to_sym, name:)
  # We cannot at the moment set active to be true directly on the international delegation factory, because this will trigger code for searchable
  # that requires a world location news to exist, but this has not been created yet at the point of creating the international delegation
  # Further refactoring of world locations / international delegations should fix this issue
  world_location.update!(active: true)
end

When(/^I visit the world locations page$/) do
  visit world_locations_path
end

Then(/^I should see the following world locations grouped under "(.*?)" in order:$/) do |letter, ordered_locations|
  within :xpath, ".//*#{xpath_class_selector('world-locations')}//*#{xpath_class_selector('js-filter-block')}[./h3[text()='#{letter}']]" do
    expect(ordered_locations.raw.map(&:first)).to eq(all(".world_location").map(&:text))
  end
end

Then(/^I should see the following international delegations in order:$/) do |ordered_delegations|
  within :xpath, ".//*#{xpath_class_selector('world-locations')}//section[@id='international-delegations']" do
    expect(ordered_delegations.raw.map(&:first)).to eq(all(".world_location").map(&:text))
  end
end
