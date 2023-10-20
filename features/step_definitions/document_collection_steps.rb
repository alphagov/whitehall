Given(/^a document collection "([^"]*)" exists$/) do |title|
  @document_collection = create(:document_collection, :with_group, title:)
end

Given(/^a published document collection "([^"]*)" exists$/) do |title|
  @document_collection = create(:published_document_collection, :with_group, title:)
end

When(/^I draft a new document collection called "(.*?)"$/) do |title|
  begin_drafting_document_collection(title:)
  click_on "Save"
  @document_collection = DocumentCollection.find_by!(title:)
end

When(/^I draft a new "(.*?)" language document collection called "(.*?)"$/) do |locale, title|
  begin_drafting_document_collection(title:, locale:)
  click_on "Save"

  locale_code = Locale.find_by_language_name(locale).code
  I18n.with_locale locale_code do
    @document_collection = DocumentCollection.find_by!(title:)
  end
end

And(/^I can see the primary locale for document collection "(.*?)" is "(.*?)"$/) do |title, locale_code|
  I18n.with_locale locale_code do
    @dc = DocumentCollection.find_by!(title:)
  end
  expect(locale_code).to eq(@dc.primary_locale)
end

When(/^I add the non whitehall url "(.*?)" for "(.*?)" to the document collection$/) do |url, title|
  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  base_path = URI.parse(url).path
  content_id = SecureRandom.uuid

  stub_publishing_api_has_lookups(base_path => content_id)
  stub_publishing_api_has_item(
    content_id:,
    base_path:,
    publishing_app: "content-publisher",
    title:,
  )

  within ".non-whitehall-disclosure" do
    find("summary").click
    fill_in "url", with: url
    click_on "Add"
  end

  within "section.group" do
    expect(page).to have_content(title)
  end
end

When(/^I add the document "(.*?)" to the document collection$/) do |document_title|
  doc_edition = Edition.find_by!(title: document_title)
  expect(@document_collection).to be_present

  visit admin_document_collection_path(@document_collection)

  click_on "Edit draft"
  click_on "Collection documents"

  fill_in "title", with: document_title
  click_on "Find"
  find("li.ui-menu-item").click
  click_on "Add"

  within "section.group" do
    expect(page).to have_content(doc_edition.title)
  end
end

When(/^I move "(.*?)" before "(.*?)" in the document collection$/) do |doc_title1, doc_title2|
  expect(@document_collection).to be_present

  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  # Simulate drag-droping document.
  execute_script %{
    (function($) {
      var doc_1_li = $('.document-list li:contains(#{doc_title1})');
      if(doc_1_li.length == 0) throw("Couldn't find li for document '#{doc_title1}' in .document-list.");

      var doc_2_li = $('.document-list li:contains(#{doc_title2})');
      if(doc_2_li.length == 0) throw("Couldn't find li for document '#{doc_title2}' in .document-list.");

      doc_2_li.before(doc_1_li.remove());

      GOVUK.instances.DocumentGroupOrdering[0].onDrop({}, {item: doc_1_li});
    })(jQuery);
  }
  # Wait for post to complete
  expect(page).to_not have_selector(".loading-spinner")
end

Then(/^I (?:can )?view the document collection in the admin$/) do
  expect(@document_collection).to be_present

  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  expect(page).to have_selector("h1", text: @document_collection.title)
end

When(/^I visit the old document series url "(.*?)"$/) do |url|
  visit url
rescue ActionController::RoutingError
  nil
end

Then(/^I should be redirected to the "(.*?)" document collection$/) do |title|
  expect(page).to have_current_path(DocumentCollection.find_by(title:).public_path)
end

Then(/^I can see in the admin that "(.*?)" is part of the document collection$/) do |document_title|
  visit admin_document_collection_path(@document_collection)
  click_on "Edit draft"
  click_on "Collection documents"

  assert_document_is_part_of_document_collection(document_title)
end

Given(/^a published publication called "(.*?)" in a published document collection$/) do |publication_title|
  @publication = create(:published_publication, title: publication_title)
  @document_collection = create(
    :published_document_collection,
    groups: [build(:document_collection_group, documents: [@publication.document])],
  )
  @group = @document_collection.groups.first
end

When(/^I redraft the document collection and remove "(.*?)" from it$/) do |document_title|
  expect(@document_collection).to be_present

  visit admin_document_collection_path(@document_collection)

  click_on "Create new edition"
  choose "Yes - information has been added, updated or removed"
  fill_in "edition_change_note", with: "changes"
  click_button "Save and go to document summary"
  save_screenshot

  click_on "Edit draft"
  click_on "Collection documents"

  check document_title
  click_on "Remove"
end

Then(/^I can see in the admin that "(.*?)" does not appear$/) do |document_title|
  refute_document_is_part_of_document_collection(document_title)
end

Then(/^I see that "(.*?)" is before "(.*?)" in the document collection$/) do |doc_title1, doc_title2|
  expect(page).to have_content(doc_title1)
  expect(body.index(doc_title1) < body.index(doc_title2)).to be(true)
end

And(/^the document collection "([^"]*)" has a group with the heading "([^"]*)"$/) do |collection_title, heading|
  document_collection = DocumentCollection.find_by!(title: collection_title)
  @group = create(:document_collection_group, heading:, document_collection:)
end

When(/^I delete the group "(.*?)"$/) do |title|
  visit admin_document_collection_groups_path(@document_collection)
  click_link "Delete #{title}"
  click_button "Delete"
end

Then(/^I can see that the group "(.*?)" has been deleted$/) do |heading|
  expect(page).to have_content "Group has been deleted"
  expect(find(".govuk-summary-card")).not_to have_content heading
end

When(/^I add the group "(.*?)"$/) do |heading|
  visit admin_document_collection_groups_path(@document_collection)
  click_link "Add group"
  fill_in "Name (required)", with: heading
  click_button "Save"
end

Then(/^I can see that the group "(.*?)" has been added$/) do |heading|
  expect(page).to have_content "New group has been created"
  expect(find(".govuk-summary-card")).to have_content heading
end

When(/^I edit the group "(.*?)"'s heading to "(.*?)"$/) do |current_heading, new_heading|
  visit admin_document_collection_groups_path(@document_collection)
  click_link "View #{current_heading}"
  click_link "Group details"
  click_link "Edit Group details"
  fill_in "Name (required)", with: new_heading
  click_button "Save"
end

Then(/^I can see that the heading has been updated to "(.*?)"$/) do |heading|
  expect(page).to have_content "Group details have been updated"
  expect(find(".govuk-summary-card")).to have_content heading
end

When(/^I remove the publication "(.*?)" from the group$/) do |title|
  visit admin_document_collection_group_document_collection_group_memberships_path(@document_collection, @group)
  click_link "Remove #{title}"
  click_button "Remove"
end

Then(/^I can see that "(.*?)" has been removed from the group$/) do |title|
  expect(page).to have_content "Document has been removed from the group"
  expect(page).to have_content "There are no documents inside this group"
  expect(page).not_to have_content title
end

And(/^the following groups exist within "([^"]*)":$/) do |collection_title, groups|
  collection = DocumentCollection.find_by!(title: collection_title)
  collection.groups = groups.hashes.map { |hash| create(:document_collection_group, heading: hash[:name]) }
  collection.save!
end

When(/^I visit the Reorder page/) do
  visit admin_document_collection_groups_path(@document_collection)
  click_link "Reorder group"
end

When(/^I visit the Reorder document page/) do
  visit admin_document_collection_group_document_collection_group_memberships_path(@document_collection, @group)
  page.should have_content "Reorder document"
  click_link("Reorder document")
end

And(/^I set the order of "([^"]*)" groups to:$/) do |collection_title, order|
  collection = DocumentCollection.find_by!(title: collection_title)

  order.hashes.each do |hash|
    group = collection.groups.select { |f| f.heading == hash[:name] }.first
    fill_in "ordering[#{group.id}]", with: hash[:order]
  end

  click_button "Save"
end

And(/^within the "([^"]*)" "([^"]*)" I set the order of the documents to:$/) do |collection_title, group_title, order|
  collection = DocumentCollection.find_by!(title: collection_title)
  group = collection.groups.find_by!(heading: group_title)
  order.hashes.each do |hash|
    membership = group.memberships.select { |f| f.document.latest_edition.title == hash[:name] }.first
    fill_in "ordering[#{membership.id}]", with: hash[:order]
  end

  click_button "Save"
end

Then(/^I can see a "([^"]*)" success flash$/) do |message|
  expect(find(".gem-c-success-alert__message").text).to eq message
end

And(/^the groups should be in the following order:/) do |list|
  actual_order = all(".govuk-summary-list dt").map(&:text)
  expected_order = list.hashes.map(&:values).flatten
  expect(actual_order).to eq(expected_order)
end

And(/^the document collection group's documents should be in the following order:/) do |list|
  actual_order = all(".govuk-table__cell:first-child").map(&:text)
  expected_order = list.hashes.map(&:values).flatten
  expect(actual_order).to eq(expected_order)
end

When(/^I select to add a new document to the collection group "([^"]*)"$/) do |search_option|
  visit admin_document_collection_group_document_collection_group_memberships_path(@document_collection, @group)
  click_link "Add document"
  choose search_option
  click_button "Next"
end

And(/^I search by "([^"]*)" for "([^"]*)"$/) do |search_type, search_term|
  fill_in "Search by #{search_type.downcase}", with: search_term
  click_button "Search"
end

And(/^I add "([^"]*)" to the document collection$/) do |document_title|
  expect(page).to have_content document_title
  click_button "Add"
end

Then(/^I should see "([^"]*)" in the list for the collection group "([^"]*)"$/) do |document_title, collection_title|
  expect(page).to have_content "'#{document_title}' added to '#{collection_title}'"
  documents = all(".govuk-table__cell").map(&:text)
  expect(documents).to include document_title
end

And(/^a GovUK Url exists "([^"]*)" with title "([^"]*)"$/) do |url, title|
  base_path = URI.parse(url).path
  content_id = SecureRandom.uuid

  stub_publishing_api_has_lookups(base_path => content_id)
  stub_publishing_api_has_item(
    content_id:,
    base_path:,
    publishing_app: "content-publisher",
    title:,
  )
end

And(/^I add URL "([^"]*)" to the document collection$/) do |url|
  fill_in "Add by URL", with: url
  click_button "Add"
end
