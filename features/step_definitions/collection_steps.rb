Given /^I create a collection called "([^"]*)" in the "([^"]*)" organisation$/ do |name, organisation|
  visit admin_root_path
  click_link "Departments & agencies"
  click_link organisation
  click_link "New collection"
  fill_in "Name", with: name
  click_button "Save"
end

Given /^collections from several other organisations exist$/ do
  create(:document_collection)
  create(:document_collection)
end

When /^I create a document called "([^"]*)" in the "([^"]*)" collection$/ do |title, collection|
  begin_drafting_publication(title)
  select collection, from: "Document collection"
  click_button "Save"
end

When /^I view the "([^"]*)" collection$/ do |collection_name|
  collection = DocumentCollection.find_by_name(collection_name)
  # It would be better to navigate to this, but at the moment we're not sure
  # where the collections will sit
  visit organisation_document_collections_path(collection.organisation)
  click_link collection_name
end

Then /^I should see links to all the documents in the "([^"]*)" collection$/ do |collection_name|
  collection = DocumentCollection.find_by_name(collection_name)
  collection.editions.each do |edition|
    assert page.has_css?("a[href='#{public_document_path(edition)}']", text: edition.title)
  end
end

Then /^I should see links back to the "([^"]*)" collection$/ do |collection_name|
  collection = DocumentCollection.find_by_name(collection_name)
  organisation = collection.organisation
  assert page.has_css?("a[href='#{admin_organisation_document_collection_path(organisation, collection)}']")
end

Then /^I should see the collections from "([^"]*)" first in the collection list$/ do |organisation_name|
  assert page.has_css?("select optgroup:nth-child(1)[label='#{organisation_name}']")
end
