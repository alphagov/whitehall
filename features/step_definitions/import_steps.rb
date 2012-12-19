When /^I import the following data as CSV as "([^"]*)":$/ do |document_type, table|
  create(:user, name: 'Automatic Data Importer')
  organisation = Organisation.find_or_create_by_name('Department Of Grooming')
  Import.use_separate_connection

  with_import_csv_file(table) do |path|
    visit new_admin_import_path
    select document_type, from: 'Type'
    attach_file 'CSV File', path
    click_button 'Save'
    click_button 'Run'

    run_last_import

    visit current_path
  end
end

Then /^the import should fail and no editions are created$/ do
  assert page.has_content?("Import failed")
end

Then /^the import succeeds, creating (\d+) imported edition with validation problems$/ do |edition_count|
  pending # express the regexp above with the code you wish you had
end
After do |scenario|
  save_and_open_page if scenario.failed?
end
