
When /^I import the following data as CSV as "([^"]*)" for "([^"]*)":$/ do |document_type, organisation_name, data|
  organisation = create(:organisation, name: organisation_name)
  import_data_as_document_type_for_organisation(data, document_type, organisation)
end

Then /^the import should fail and no editions are created$/ do
  assert page.has_content?("Import failed")
end

Then /^the import succeeds, creating (\d+) imported publications? for "([^"]*)" with "([^"]*)" publication type$/ do |edition_count, organisation_name, publication_sub_type_slug|
  organisation = Organisation.find_by_name(organisation_name)
  publication_sub_type  = PublicationType.find_by_slug(publication_sub_type_slug)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of Publication, edition
  assert_equal organisation, edition.organisations.first
  assert_equal publication_sub_type, edition.publication_type
end

Then /^the import succeeds, creating (\d+) imported speech(?:es)? with "([^"]*)" speech type and with no deliverer set$/ do |edition_count, speech_type_slug|
  speech_type = SpeechType.find_by_slug(speech_type_slug)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of Speech, edition
  assert_equal speech_type, edition.speech_type
end

Then /^the import succeeds, creating (\d+) imported news article for "([^"]*)" with "([^"]*)" news article type$/ do |edition_count, organisation_name, news_article_type_slug|
  organisation = Organisation.find_by_name(organisation_name)
  news_article_type  = NewsArticleType.find_by_slug(news_article_type_slug)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of NewsArticle, edition
  assert_equal organisation, edition.organisations.first
  assert_equal news_article_type, edition.news_article_type
end

Then /^the import should fail with errors about organisation and sub type and no editions are created$/ do
  assert page.has_content?("Import failed")
  assert page.has_content?("Unable to find Organisation named 'weird organisation'")
  assert page.has_content?("Unable to find Publication type with slug 'weird type'")

  assert_equal 0, Edition.count
end

Then /^I can't make the imported (?:publication|speech|news article) into a draft edition yet$/ do
  visit_document_preview Edition.imported.last.title

  assert page.has_css?('input[type=submit][disabled=disabled][value="Convert to draft"]')
end

When /^I set the imported publication's type to "([^"]*)"$/ do |publication_sub_type|
  begin_editing_document Edition.imported.last.title
  select publication_sub_type, from: 'Publication type'
  click_on 'Save'
end

When /^I set the imported news article's type to "([^"]*)"$/ do |news_article_type|
  begin_editing_document Edition.imported.last.title
  select news_article_type, from: 'News article type'
  click_on 'Save'
end

Then /^I can make the imported (?:publication|speech|news article) into a draft edition$/ do
  edition = Edition.imported.last
  visit_document_preview edition.title

  click_on 'Convert to draft'

  edition.reload
  assert edition.draft?
end

Then /^the imported speech's organisation is set to "([^"]*)"$/ do |organisation_name|
  assert_equal organisation_name, Edition.imported.last.organisations.first.name
end

When /^I set the imported speech's type to "([^"]*)"$/ do |speech_type|
  begin_editing_document Edition.imported.last.title
  select speech_type, from: 'Type'
  click_on 'Save'
end

When /^I set the deliverer of the speech to "([^"]*)" from the "([^"]*)"$/ do |person_name, organisation_name|
  person = find_or_create_person(person_name)
  organisation = create(:ministerial_department, name: organisation_name)
  role = create(:role, organisations: [organisation])
  create(:role_appointment, role: role, person: person)

  begin_editing_document Edition.imported.last.title
  select person_name, from: 'Delivered by'
  click_on 'Save'
end

Then /^the speech's organisation is set to "([^"]*)"$/ do |organisation_name|
  assert_equal Edition.last.organisations, [Organisation.find_by_name(organisation_name)]
end

Then /^I can delete the imported edition if I choose to$/ do
  edition = Edition.imported.last

  visit_document_preview edition.title
  click_on 'Delete'

  assert edition.reload.deleted?
end
