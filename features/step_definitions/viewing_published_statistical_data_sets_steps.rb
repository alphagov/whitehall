Given /^a document collection "([^"]*)"$/ do |title|
  @document_collection = create(:document_collection, :with_group, title: title)
end

Given /^a published publication that's part of the "([^"]*)" document collection$/ do |document_collection_title|
  draft = create(:draft_publication)
  document_collection = DocumentCollection.find_by_title!(document_collection_title)
  document_collection.groups.first.documents << draft.document
  draft.perform_force_publish
end

Given /^a published statistical data set "([^"]*)" that's part of the "([^"]*)" document collection$/ do |data_set_title, document_collection_title|
  document_collection = DocumentCollection.find_by_title!(document_collection_title)
  document_collection.groups.first.documents << create(:published_statistical_data_set, title: data_set_title).document
end

Given /^a published statistical data set "([^"]*)"$/ do |data_set_title|
  create(:published_statistical_data_set, title: data_set_title)
end

When /^I follow the link to the "([^"]*)" document collection$/ do |document_collection_title|
  within find('.document-collections', match: :first) do
    click_link document_collection_title
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
