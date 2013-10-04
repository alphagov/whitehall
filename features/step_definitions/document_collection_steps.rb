Given(/^a document collection "([^"]*)" exists$/) do |title|
  @document_collection = create(:document_collection, :with_group, title: title)
end

Given(/^a published document collection "([^"]*)" exists$/) do |title|
  @document_collection = create(:published_document_collection, :with_group, title: title)
end

Given(/^a published publication called "(.*?)" in the document collection "(.*?)"$/) do |publication_title, collection_title|
  @publication = create(:published_publication, title: publication_title)
  @document_collection = create(:document_collection, :with_group, title: collection_title)
  @group = @document_collection.groups.first
  @group.documents = [@publication.document]
end

Given(/^I'm editing the document collection "(.*?)"$/) do |document_collection_title|
  @document_collection = DocumentCollection.find_by_title!(document_collection_title)
  visit admin_document_collection_path(@document_collection)
end

When(/^I draft a new document collection called "(.*?)"$/) do |title|
  visit new_admin_document_collection_path
  within ".edition-form" do
    fill_in "Title",   with: title
    fill_in "Summary", with: "a summary"
    fill_in "Body",    with: "a body"

    click_on "Save"
  end
  @document_collection = DocumentCollection.find_by_title!(title)
end

When(/^I add the document "(.*?)" to the document collection$/) do |document_title|
  doc_edition = Edition.find_by_title!(document_title)
  refute @document_collection.nil?, "No document collection to act on."

  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  fill_in 'title', with: document_title
  click_on 'Find'
  find('li.ui-menu-item').click
  click_on 'Add'

  within ('section.group') do
    assert page.has_content? doc_edition.title
  end

  # assert @document_collection.groups.first.documents.include?(doc_edition.document), 'Document has not been added to the collection'
end

When(/^I remove the document "(.*?)" from the document collection$/) do |document_title|
  # doc_edition = Edition.find_by_title!(document_title)
  refute @document_collection.nil?, "No document collection to act on."

  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  check document_title
  click_on "Remove"
end

Then(/^I (?:can )?preview the document collection$/) do
  refute @document_collection.nil?, "No document collection to act on."

  visit admin_document_collection_path(@document_collection)
  visit_link_href "Preview on website"

  assert page.has_selector?("h1", text: @document_collection.title)
  assert page.has_content? @document_collection.summary
  assert page.has_content? @document_collection.body
end

Then(/^I see that the document "(.*?)" is (not )?part of the document collection$/) do |document_title, is_not|
  within '#document_collection' do
    if is_not
      refute page.has_content? document_title
    else
      assert page.has_content? document_title
    end
  end
end

Then(/^I should see links back to the collection$/) do
  @document_collection
  assert page.has_css?("a[href='#{public_document_path(@document_collection)}']")
end

When(/^I visit the old document series url "(.*?)"$/) do |url|
  visit url
end

Then(/^I should be redirected to the "(.*?)" document collection$/) do |title|
  dc = DocumentCollection.find_by_title(title)
  assert_equal public_document_path(dc), page.current_path
end