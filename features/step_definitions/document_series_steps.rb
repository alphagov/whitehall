Given /^I create a series called "([^"]*)" in the "([^"]*)" organisation$/ do |name, organisation|
  visit admin_root_path
  click_link "Departments & agencies"
  click_link organisation
  click_link "Document series"
  click_link "New series"
  fill_in "Name", with: name
  fill_in "Summary", with: "This is a summary of #{name}"
  click_button "Save"
end

Given /^a document series "([^"]*)" exists$/ do |name|
  create(:document_series, name: name)
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

Then /^I should see a summary of the series clearly displayed$/ do
  assert page.has_css?(".summary p", DocumentSeries.last.summary)
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

Given /^a series "([^"]*)" for the organisation "([^"]*)"$/ do |series_name, organisation_name|
  organisation = create(:organisation, name: organisation_name)
  series = create(:document_series, name: series_name, organisation: organisation)
end

Given /^a published publication "([^"]*)" in the series "([^"]*)"$/ do |publication_name, series_name|
  series = DocumentSeries.find_by_name(series_name)
  publication = create(:published_publication, title: publication_name, document_series: [series], organisations: [series.organisation])
end

Then /^I should see the publication "([^"]*)" belongs to the "([^"]*)" series$/ do |publication_name, series_name|
  publication = Publication.find_by_title(publication_name)
  series = DocumentSeries.find_by_name(series_name)
  within record_css_selector(publication) do
    assert page.has_css? "a[href='#{organisation_document_series_path(series.organisation, series)}']", text: series.name
  end
end
