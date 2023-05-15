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
  expect(page).to have_current_path(public_document_path(DocumentCollection.find_by(title:)))
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
  fill_in_change_note_if_required
  click_button "Save and continue"
  click_button "Update tags"

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
