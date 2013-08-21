Given /^a document series "([^"]*)"$/ do |name|
  create(:document_series, name: name)
end

Given /^a published publication that's part of the "([^"]*)" document series$/ do |document_series_name|
  document_series = DocumentSeries.find_by_name!(document_series_name)
  document_series.documents << create(:published_publication).document
end

Given /^a published statistical data set "([^"]*)" that's part of the "([^"]*)" document series$/ do |data_set_title, document_series_name|
  document_series = DocumentSeries.find_by_name!(document_series_name)
  document_series.documents << create(:published_statistical_data_set, title: data_set_title).document
end

Given /^a published statistical data set "([^"]*)"$/ do |data_set_title|
  create(:published_statistical_data_set, title: data_set_title)
end

When /^I follow the link to the "([^"]*)" document series$/ do |document_series_name|
  within find('.document-series', match: :first) do
    click_link document_series_name
  end
end

When /^I follow the link to the "([^"]*)" statistical data set$/ do |data_set_title|
  within('.statistical_data_set.document-row') do
    click_link data_set_title
  end
end

Then /^I should see the "([^"]*)" statistical data set$/ do |data_set_title|
  assert page.has_css?('h1', text: data_set_title)
end
