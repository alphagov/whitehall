Given(/^a document series "([^"]*)" exists$/) do |title|
  @document_series = create(:document_series, :with_group, title: title)
end

Given(/^a published publication called "(.*?)" in the document series "(.*?)"$/) do |publication_title, series_title|
  @publication = create(:published_publication, title: publication_title)
  @document_series = create(:document_series, :with_group, title: series_title)
  @group = @document_series.groups.first
  @group.documents = [@publication.document]
end

Given(/^I'm editing the document series "(.*?)"$/) do |document_series_title|
  @document_series = DocumentSeries.find_by_title!(document_series_title)
  visit admin_document_series_path(@document_series)
end

When(/^I draft a new document series called "(.*?)"$/) do |title|
  visit new_admin_document_series_path
  within ".edition-form" do
    fill_in "Title",   with: title
    fill_in "Summary", with: "a summary"
    fill_in "Body",    with: "a body"

    click_on "Save"
  end
  @document_series = DocumentSeries.find_by_title!(title)
end

When(/^I add the document "(.*?)" to the document series$/) do |document_title|
  doc_edition = Edition.find_by_title!(document_title)
  refute @document_series.nil?, "No document series to act on."

  visit admin_document_series_path(@document_series)
  click_on "Edit draft"
  click_on "Series documents"

  fill_in 'title', with: document_title
  click_on 'Find'
  find('li.ui-menu-item').click
  click_on 'Add'

  within ('section.group') do
    assert page.has_content? doc_edition.title
  end

  # assert @document_series.groups.first.documents.include?(doc_edition.document), 'Document has not been added to the series'
end

When(/^I remove the document "(.*?)" from the document series$/) do |document_title|
  # doc_edition = Edition.find_by_title!(document_title)
  refute @document_series.nil?, "No document series to act on."

  visit admin_document_series_path(@document_series)
  click_on "Edit draft"
  click_on "Series documents"

  check document_title
  click_on "Remove"
end

Then(/^I (?:can )?preview the document series$/) do
  refute @document_series.nil?, "No document series to act on."

  visit admin_document_series_path(@document_series)
  visit_link_href "Preview on website"

  assert page.has_selector?("h1", text: @document_series.title)
  assert page.has_content? @document_series.summary
  assert page.has_content? @document_series.body
end

Then(/^I see that the document "(.*?)" is (not )?part of the document series$/) do |document_title, is_not|
  within '#document_series' do
    if is_not
      refute page.has_content? document_title
    else
      assert page.has_content? document_title
    end
  end
end

Then(/^I should see links back to the series$/) do
  @document_series
  assert page.has_css?("a[href='#{document_series_path(@document_series)}']")
end
