Given(/^a document collection "([^"]*)" exists$/) do |title|
  @document_collection = create(:document_collection, :with_group, title: title)
end

Given(/^a published document collection "([^"]*)" exists$/) do |title|
  @document_collection = create(:published_document_collection, :with_group, title: title)
end

Given(/^a published publication called "(.*?)" in the document collection "(.*?)"$/) do |publication_title, collection_title|
  @publication = create(:published_publication, title: publication_title)
  @document_collection = create(:published_document_collection,
    title: collection_title,
    groups: [build(:document_collection_group, documents: [@publication.document])]
  )
  @group = @document_collection.groups.first
end

When(/^I draft a new document collection called "(.*?)"$/) do |title|
  begin_drafting_document_collection(title: title)
  click_on "Save"
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
end

When(/^I move "(.*?)" before "(.*?)" in the document collection$/) do |doc_title_1, doc_title_2|
  refute @document_collection.nil?, "No document collection to act on."

  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  #Simulate drag-droping document.
  page.execute_script %Q{
    (function($) {
      var doc_1_li = $('.document-list li:contains(#{doc_title_1})');
      if(doc_1_li.length == 0) throw("Couldn't find li for document '#{doc_title_1}' in .document-list.");

      var doc_2_li = $('.document-list li:contains(#{doc_title_2})');
      if(doc_2_li.length == 0) throw("Couldn't find li for document '#{doc_title_2}' in .document-list.");

      doc_2_li.before(doc_1_li.remove());

      GOVUK.instances.DocumentGroupOrdering[0].onDrop({}, {item: doc_1_li});
    })(jQuery);
  }
end

Then(/^I (?:can )?preview the document collection$/) do
  refute @document_collection.nil?, "No document collection to act on."

  visit preview_document_path(@document_collection)

  assert page.has_selector?("h1", text: @document_collection.title)
  assert page.has_content? @document_collection.summary
  assert page.has_content? @document_collection.body
end

Then(/^I see that the document "(.*?)" is not part of the document collection$/) do |document_title|
  refute_document_is_part_of_document_collection(document_title)
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

Then(/^I can see in the preview that "(.*?)" is part of the document collection$/) do |document_title|
  visit preview_document_path(@document_collection)
  assert_document_is_part_of_document_collection(document_title)
end

Given(/^a published publication called "(.*?)" in a published document collection$/) do |publication_title|
  @publication = create(:published_publication, title: publication_title)
  @document_collection = create(:published_document_collection,
    groups: [build(:document_collection_group, documents: [@publication.document])]
  )
  @group = @document_collection.groups.first
end

When(/^I redraft the document collection and remove "(.*?)" from it$/) do |document_title|
  refute @document_collection.nil?, "No document collection to act on."

  visit admin_document_collection_path(@document_collection)
  click_on "Create new edition to edit"
  click_on "Collection documents"

  check document_title
  click_on "Remove"
end

Then(/^I can see in the preview that "(.*?)" does not appear$/) do |document_title|
  visit preview_document_path(@document_collection)
  refute_document_is_part_of_document_collection(document_title)
end

Then(/^I see that "(.*?)" is before "(.*?)" in the document collection$/) do |doc_title_1, doc_title_2|
  assert page.has_content? doc_title_1
  assert page.body.index(doc_title_1) < page.body.index(doc_title_2), "Expected #{doc_title_1} to be before #{doc_title_2}"
end
