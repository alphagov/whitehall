And(/^a featurable standard edition called "([^"]*)" exists$/) do |title|
  @featurable_edition = create(:standard_edition, title:)
end

Given(/^the featurable standard edition is linked to an edition with the title "([^"]*)"$/) do |title|
  # Only topical events can be linked through configurable associations at the moment,
  # so we need to use the topical_event_documents association to link the standard edition to another edition.
  # In future, we should make a generic association suitable for both topical events and any other associable document type.
  create(:publication, :published, title:, topical_event_documents: [@featurable_edition.document])
end

And(/^two featurings exist for the edition$/) do
  featured_edition_1 = create(:published_standard_edition, title: "Featured Edition 1")
  featured_edition_2 = create(:published_standard_edition, title: "Featured Edition 2")
  feature_list = @featurable_edition.feature_lists.create!(locale: @featurable_edition.primary_locale)
  create(:feature, feature_list:, document: featured_edition_1.document)
  create(:feature, feature_list:, document: featured_edition_2.document)
end

When(/^I visit the standard edition featuring index page$/) do
  visit edit_admin_standard_edition_path(@featurable_edition)
  click_link "Featured"
end

And(/^I set the order of the edition featurings to:$/) do |featurings_order|
  click_link "Reorder pages"

  featurings_order.hashes.each do |hash|
    featuring = @featurable_edition.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    fill_in "ordering[#{featuring.id}]", with: hash[:order]
  end

  click_button "Update order"
end

Then(/^the edition featurings should be in the following order:$/) do |featurings_titles|
  featuring_titles = all("table td:first").map(&:text)

  featurings_titles.hashes.each_with_index do |hash, index|
    featuring = @featurable_edition.feature_lists.first.features.select { |f| f.to_s == hash[:title] }.first
    expect(featuring.to_s).to eq(featuring_titles[index])
  end
end

Given(/^the standard edition has an external website link with the title "([^"]*)"$/) do |title|
  create(:offsite_link, editions: [@featurable_edition], title:)
end

And(/^I create a new external website link with the title "([^"]*)"$/) do |title|
  click_link "Add an external link"

  fill_in "Title (required)", with: title
  fill_in "Summary (required)", with: "Summary"
  select "Alert"
  fill_in "URL (required)", with: "https://www.gov.uk/jobsearch"

  click_button "Save"
end

Then(/^I can see the external website link with the title "([^"]*)"$/) do |title|
  within "#non_govuk_government_links_tab" do
    expect(find("table td:first").text).to eq title
  end
end

And(/^I update the title of an external website link from "([^"]*)" to "([^"]*)"$/) do |current_title, new_title|
  within "#non_govuk_government_links_tab" do
    click_link "Edit #{current_title}"
  end
  fill_in "Title (required)", with: new_title
  click_button "Save"
end

And(/^I feature the external website link called "([^"]*)"$/) do |title|
  within "#non_govuk_government_links_tab" do
    click_link "Feature #{title}"
  end

  attach_file "Image (required)", jpg_image
  click_button "Save"
end

Then(/^I see that the external website link called "([^"]*)" has been featured$/) do |title|
  within "#currently_featured_tab" do
    expect(find("table td:first").text).to eq title
  end
end

And(/^I delete the external website link called "([^"]*)"$/) do |title|
  within "#non_govuk_government_links_tab" do
    click_link "Delete #{title}"
  end
  click_button "Delete"
end

Then(/^I can see that the external website link called "([^"]*)" has been deleted$/) do |title|
  within "#non_govuk_government_links_tab" do
    expect(page).not_to have_content title
  end
end
