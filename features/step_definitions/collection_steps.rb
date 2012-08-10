Given /^I create a collection called "([^"]*)" in the "([^"]*)" organisation$/ do |name, organisation|
  visit admin_root_path
  click_link "Departments & agencies"
  click_link organisation
  click_link "New collection"
  fill_in "Name", with: name
  click_button "Save"
end

Given /^collections from several other organisations exist$/ do
  create(:document_collection, organisation: alpha)
  create(:document_collection, organisation: beta)
end

When /^I create a document called "([^"]*)" in the "([^"]*)" collection$/ do |title, collection|
  begin_drafting_publication(title)
  select collection, from: "Collection"
  click_button "Save"
end

When /^I view the "([^"]*)" collection$/ do |collection_name|
  collection = DocumentCollection.find_by_name(collection_name)
  # It would be better to navigate to this, but at the moment we're not sure
  # where the collections will sit
  visit organisation_collection_path(collection.organisation, collection)
end

Then /^I should see links to all the documents in the "([^"]*)" collection$/ do |collection_name|
  collection = DocumentCollection.find_by_name(collection_name)
  collection.documents.each do |document|
    assert page.has_css?("a[href='#{public_document_path(document)}']", text: document.title)
  end
end

Then /^I should see links back to the "([^"]*)" collection$/ do |collection_name|
  collection = DocumentCollection.find_by_name(collection_name)
  organisation = collection.organisation
  assert page.has_css?("a[href='#{organisation_collection_path(organisation, collection)}']")
end

Then /^I should see the collections from "([^"]*)" first in the collection list$/ do |organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  collections = organisation.document_collections
  pending
end
