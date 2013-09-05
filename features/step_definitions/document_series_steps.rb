Given(/^a document series "([^"]*)" exists$/) do |name|
  @document_series = create(:document_series, :with_group, name: name)
end

Given(/^a published publication called "(.*?)" in the series "(.*?)"$/) do |publication_name, series_name|
  @publication = create(:published_publication, title: publication_name)
  @document_series = create(:document_series, :with_group, name: series_name)
  @group = @document_series.groups.first
  @group.documents = [@publication.document]
end

Then(/^I should be able to search for "(.*?)" and add the document to the series$/) do |search_text|
  visit admin_organisation_document_series_path(@document_series.organisation, @document_series)
  click_on 'Series documents'
  fill_in 'title', with: search_text
  click_button 'Find'
  screenshot('find-clicked')
  find('li.ui-menu-item').click
  screenshot('menu-clicked')

  edition = Edition.last
  click_button 'Add'
  screenshot('add-clicked')

  within ('section.group') do
    assert page.has_content? edition.title
  end

  assert @document_series.groups.first.documents.include?(edition.document), 'Document has not been added to the series'
end

Then(/^I should be able to remove the publication from the series$/) do
  visit admin_organisation_document_series_path(@document_series.organisation, @document_series)
  click_on 'Series documents'
  find('ol.document-list li:first-child input[type="checkbox"]').click
  click_on 'Remove'

  page.has_content?('document removed')
  refute @document_series.reload.documents.include?(@publication.document), "Document has not been removed from the series"
end

Then(/^I should see links back to the series$/) do
  organisation = @document_series.organisation
  assert page.has_css?("a[href='#{organisation_document_series_path(organisation, @document_series)}']")
end
