Given(/^no world locations exist$/) do
  WorldLocation.delete_all
end

And(/^a world location news exists$/) do
  @world_location = build(:world_location, slug: "foo")
  @world_location_news = create(:world_location_news, world_location: @world_location)
end

When(/^I visit the world location news index page$/) do
  visit admin_world_location_news_index_path
end

When(/^I click the Inactive tab$/) do
  click_link "Inactive", class: "govuk-tabs__tab"
end

Then(/^I should see the "([^"]*)" message$/) do |message|
  expect(page).to have_selector("p", text: "#{message}.")
end

Given(/^the world location has a feature list with (\d+) featured (?:document|documents)$/) do |count|
  @feature_list = create(:feature_list, featurable: @world_location_news)

  count.times do |i|
    edition = create(:edition, :published, title: "Document #{i + 1}")

    create(:feature, feature_list: @feature_list, document: edition.document)
  end
end

When(/^I visit the world location news page$/) do
  visit features_admin_world_location_news_path(@world_location, locale: I18n.default_locale)
end

And(/^I set the order of the featured documents to:$/) do |featured_documents_order|
  visit features_admin_world_location_news_path(@world_location, locale: I18n.default_locale)
  click_link "Reorder documents"

  featured_documents_order.hashes.each do |hash|
    feature = @feature_list.features.select { |f| f.to_s == hash[:title] }.first
    fill_in "ordering[#{feature.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the featured documents should be in the following order:$/) do |featured_documents_titles|
  document_titles = all("table td:first").map(&:text)

  featured_documents_titles.hashes.each_with_index do |hash, index|
    feature = @feature_list.features.select { |f| f.to_s == hash[:title] }.first
    expect(feature.to_s).to eq(document_titles[index])
  end
end

And(/^I unfeature the document$/) do
  within "#currently_featured_tab" do
    click_link "Unfeature"
  end
  click_button "Unfeature"
end

Then(/^I see that I have no featured documents$/) do
  within "#currently_featured_tab" do
    expect(page).to have_content "There are currently no featured documents."
  end
end

Given(/^there is a published document with the tile "([^"]*)"$/) do |title|
  create(:edition, :published, title:)
end

And(/^filter documents by all organisations$/) do
  select "All locations"
  click_button "Search"
end

And(/^I feature "([^"]*)"$/) do |title|
  click_link "Feature #{title}"

  attach_file "Image (required)", jpg_image
  click_button "Save"
end

Then(/^I see that "([^"]*)" has been featured$/) do |title|
  within "#currently_featured_tab" do
    expect(find("table td:first").text).to eq title
  end
end

Given(/^the world location has an offsite link with the title "([^"]*)"$/) do |title|
  create(:offsite_link, parent_type: "WorldLocationNews", parent: @world_location_news, title:)
end

And(/^I create a new a non-GOV.UK link with the title "([^"]*)"$/) do |title|
  click_link "Create new link"

  fill_in "Title (required)", with: title
  fill_in "Summary (required)", with: "Summary"
  fill_in "URL (required)", with: "https://www.gov.uk/jobsearch"

  click_button "Save"
end

Then(/^I can see the non-GOV.UK link with the title "([^"]*)"$/) do |title|
  within "#non_govuk_government_links_tab" do
    expect(find("table td:first").text).to eq title
  end
end

And(/^I update the title of a featured link from "([^"]*)" to "([^"]*)"$/) do |current_title, new_title|
  click_link "Edit #{current_title}"
  fill_in "Title (required)", with: new_title
  click_button "Save"
end

And(/^I delete "([^"]*)"$/) do |title|
  click_link "Delete #{title}"
  click_button "Delete"
end

Then(/^I can see that "([^"]*)" has been deleted$/) do |title|
  within "#non_govuk_government_links_tab" do
    expect(page).not_to have_content title
  end
end
