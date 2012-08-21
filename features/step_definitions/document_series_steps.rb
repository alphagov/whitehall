Given /^I create a series called "([^"]*)" in the "([^"]*)" organisation$/ do |name, organisation|
  visit admin_root_path
  click_link "Departments & agencies"
  click_link organisation
  click_link "New series"
  fill_in "Name", with: name
  click_button "Save"
end

Given /^series from several other organisations exist$/ do
  create(:document_series)
  create(:document_series)
end

When /^I create a document called "([^"]*)" in the "([^"]*)" series$/ do |title, series|
  begin_drafting_publication(title)
  select series, from: "Document series"
  click_button "Save"
end

When /^I view the "([^"]*)" series$/ do |series_name|
  series = DocumentSeries.find_by_name(series_name)
  # It would be better to navigate to this, but at the moment we're not sure
  # where the seriess will sit
  visit organisation_document_series_path(series.organisation, series)
end

Then /^I should see links to all the documents in the "([^"]*)" series$/ do |series_name|
  series = DocumentSeries.find_by_name(series_name)
  series.editions.each do |edition|
    assert page.has_css?("a[href='#{public_document_path(edition)}']", text: edition.title)
  end
end

Then /^I should see links back to the "([^"]*)" series$/ do |series_name|
  series = DocumentSeries.find_by_name(series_name)
  organisation = series.organisation
  assert page.has_css?("a[href='#{organisation_document_series_path(organisation, series)}']")
end

Then /^I should see the series from "([^"]*)" first in the series list$/ do |organisation_name|
  assert page.has_css?("select optgroup:nth-child(1)[label='#{organisation_name}']")
end
