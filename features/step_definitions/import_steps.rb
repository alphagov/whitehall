Given /^a (topic|document series|mainstream category|policy) with the slug "([^"]*)" exists$/ do |type, slug|
  o = create(type.parameterize.underscore)
  o.update_attributes!(slug: slug)
end

When /^I import the following data as CSV as "([^"]*)" for "([^"]*)":$/ do |document_type, organisation_name, data|
  organisation = Organisation.find_by_name(organisation_name) || create(:organisation, name: organisation_name)
  import_data_as_document_type_for_organisation(data, document_type, organisation)
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

Then /^the import succeeds, creating (\d+) imported publications? for "([^"]*)" with no publication date$/ do |edition_count, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of Publication, edition
  assert_equal organisation, edition.organisations.first
  assert_nil edition.publication_date
end

Then /^the import succeeds, creating (\d+) imported publication for "([^"]*)"$/ do |edition_count, organisation_name|
  import = Import.last
  assert_equal :succeeded, import.status
  assert_equal edition_count.to_i, import.documents.count

  organisation = Organisation.find_by_name(organisation_name)
  edition = import.editions.last
  assert_kind_of Publication, edition
  assert_equal organisation, edition.organisations.first
end

Then /^the imported publication has an html version with the title "([^"]*)" and body "([^"]*)"$/ do |html_title, html_body|
  publication = Import.last.editions.last
  assert_equal html_title, publication.html_version.title
  assert_equal html_body, publication.html_version.body
end

Then /^the import succeeds, creating (\d+) imported speech(?:es)? with "([^"]*)" speech type and with no deliverer set$/ do |edition_count, speech_type_slug|
  speech_type = SpeechType.find_by_slug(speech_type_slug)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of Speech, edition
  assert_equal speech_type, edition.speech_type
  assert_nil edition.role_appointment
end

Then /^the import succeeds, creating (\d+) imported speech(?:es)? for "([^"]*)" with no delivered on date$/ do |edition_count, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of Speech, edition
  assert_equal organisation, edition.organisations.first
  assert_nil edition.delivered_on
end

Then /^the import succeeds, creating (\d+) imported news articles? for "([^"]*)" with "([^"]*)" news article type$/ do |edition_count, organisation_name, news_article_type_slug|
  organisation = Organisation.find_by_name(organisation_name)
  news_article_type  = NewsArticleType.find_by_slug(news_article_type_slug)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of NewsArticle, edition
  assert_equal organisation, edition.organisations.first
  assert_equal news_article_type, edition.news_article_type
end

Then /^the import succeeds, creating (\d+) imported news articles? for "([^"]*)" with no first published date$/ do |edition_count, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of NewsArticle, edition
  assert_equal organisation, edition.organisations.first
  assert_nil edition.first_published_at
end

Then /^the import succeeds, creating (\d+) imported consultations? for "([^"]*)" with no opening or closing date$/ do |edition_count, organisation_name|
  organisation = Organisation.find_by_name(organisation_name)
  assert_equal edition_count.to_i, Edition.imported.count

  edition = Edition.imported.first
  assert_kind_of Consultation, edition
  assert_equal organisation, edition.organisations.first
  assert_nil edition.opening_on
  assert_nil edition.closing_on
end

Then /^the import should fail with errors about organisation and sub type and no editions are created$/ do
  assert page.has_content?("Import failed")
  assert page.has_content?("Unable to find Organisation named 'weird organisation'")
  assert page.has_content?("Unable to find Publication type with slug 'weird type'")

  assert_equal 0, Edition.count
end

Then /^the import should fail with errors about an unrecognised policy$/ do
  assert page.has_content?("Import failed")
  assert page.has_content?("Unable to find Policy with slug 'non-existent-policy'")

  assert_equal 0, Edition.count
end

Then /^I can't make the imported (?:publication|speech|news article|consultation) into a draft edition yet$/ do
  visit_document_preview Edition.imported.last.title

  assert page.has_css?('input[type=submit][disabled=disabled][value="Convert to draft"]')
end

When /^I set the imported publication's type to "([^"]*)"$/ do |publication_sub_type|
  begin_editing_document Edition.imported.last.title
  select publication_sub_type, from: 'Publication type'
  click_on 'Save'
end

When /^I set the imported publication's publication date to "([^"]*)"$/ do |new_publication_date|
  begin_editing_document Edition.imported.last.title
  select_date new_publication_date, from: "Publication date"
  click_on 'Save'
end

When /^I set the imported news article's type to "([^"]*)"$/ do |news_article_type|
  begin_editing_document Edition.imported.last.title
  select news_article_type, from: 'News article type'
  click_on 'Save'
end

When /^I set the imported news article's first published date to "([^"]*)"$/ do |new_first_published_date|
  begin_editing_document Edition.imported.last.title
  select_date new_first_published_date, from: "First published at"
  click_on 'Save'
end

Then /^I can make the imported (?:publication|speech|news article|consultation) into a draft edition$/ do
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

When /^I set the imported speech's delivered on date to "([^"]*)"$/ do |new_delivered_on_date|
  begin_editing_document Edition.imported.last.title
  select_date new_delivered_on_date, from: "Delivered on"
  click_on 'Save'
end

When /^I set the deliverer of the speech to "([^"]*)" from the "([^"]*)"$/ do |person_name, organisation_name|
  person = find_or_create_person(person_name)
  organisation = create(:ministerial_department, name: organisation_name)
  role = create(:role, organisations: [organisation])
  create(:role_appointment, role: role, person: person)

  begin_editing_document Edition.imported.last.title
  select person_name, from: 'Speaker'
  click_on 'Save'
end

Then /^the speech's organisation is set to "([^"]*)"$/ do |organisation_name|
  assert_equal Edition.last.organisations, [Organisation.find_by_name(organisation_name)]
end

When /^I set the imported consultation's opening date to "([^"]*)"$/ do |new_opening_date|
  begin_editing_document Edition.imported.last.title
  select_date new_opening_date, from: "Opening Date"
  click_on 'Save'
end

When /^I set the imported consultation's closing date to "([^"]*)"$/ do |new_closing_date|
  begin_editing_document Edition.imported.last.title
  select_date new_closing_date, from: "Closing Date"
  click_on 'Save'
end

Then /^I can delete the imported edition if I choose to$/ do
  edition = Edition.imported.last

  visit_document_preview edition.title
  click_on 'Delete'

  assert edition.reload.deleted?
end

Then /^the import succeeds creating (\d+) detailed guidance document$/ do |n|
  assert_equal [], Import.last.import_errors
  assert_equal :succeeded, Import.last.status
  assert_equal n.to_i, Import.last.documents.where(document_type: DetailedGuide.name).to_a.size
end

Then /^the imported detailed guidance document has the following associations:$/ do |expected_table|
  detailed_guide_document = Import.last.documents.where(document_type: DetailedGuide.name).first
  edition = detailed_guide_document.editions.first
  expected_table.hashes.each do |row|
    assert_equal edition.send(row["Name"].to_sym).map(&:slug), row["Slugs"].split(/, +/)
  end
end

Then /^the import succeeds creating (\d+) case stud(?:y|ies)$/ do |n|
  assert_equal [], Import.last.import_errors
  assert_equal :succeeded, Import.last.status
  assert_equal n.to_i, Import.last.documents.where(document_type: CaseStudy.name).to_a.size
end

Then /^the imported case study has the following associations:$/ do |expected_table|
  case_study = Import.last.documents.where(document_type: CaseStudy.name).first
  edition = case_study.editions.first
  expected_table.hashes.each do |row|
    assert_equal edition.send(row["Name"].to_sym).map(&:slug), row["Slugs"].split(/, +/)
  end
end

Then /^the imported news article has (?:a|an) "([^"]*)" locale translation$/ do |locale|
  news_article = Import.last.documents.where(document_type: NewsArticle.name).first.latest_edition
  assert news_article.available_in_locale?(locale), "News article should have been translated into #{locale}"
end
