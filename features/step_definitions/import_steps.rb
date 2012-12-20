
When /^I import the following data as CSV as "([^"]*)" for "([^"]*)":$/ do |document_type, organisation_name, table|
  create(:user, name: 'Automatic Data Importer')
  organisation = create(:organisation, name: organisation_name)
  Import.use_separate_connection

  with_import_csv_file(table) do |path|
    visit new_admin_import_path
    select document_type, from: 'Type'
    attach_file 'CSV File', path
    select organisation_name, from: 'Default organisation'
    click_button 'Save'
    click_button 'Run'

    run_last_import

    visit current_path
  end
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

Then /^the import should fail with errors about organisation and sub type and no editions are created$/ do
  assert page.has_content?("Import failed")
  assert page.has_content?("Unable to find Organisation named 'weird organisation'")
  assert page.has_content?("Unable to find Publication type with slug 'weird type'")

  assert_equal 0, Edition.count
end

# After do |scenario|
#   save_and_open_page if scenario.failed?
# end
