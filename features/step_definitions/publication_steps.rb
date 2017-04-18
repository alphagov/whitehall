Given /^a list of publications exists$/ do
  stub_organisation_homepage_in_content_store
end

Given /^a published publication "([^"]*)" exists that is about "([^"]*)"$/ do |publication_title, world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  create(:published_publication, title: publication_title, world_locations: [world_location])
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  publication = create(:submitted_publication, :with_file_attachment, title: title, body: "!@1")
  @attachment = publication.attachments.first
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  publication = create(:published_publication, :with_file_attachment, title: title, body: "!@1")
  @attachment = publication.attachments.first
end

When /^I start drafting a new publication "([^"]*)"$/ do |title|
  begin_drafting_publication(title)
  click_button "Save"
end

When /^I draft a new publication "([^"]*)"$/ do |title|
  begin_drafting_publication(title)
  click_button "Save"
  add_external_attachment
end

Given /^"([^"]*)" drafts a new publication "([^"]*)"$/ do |user_name, title|
  user = User.find_by(name: user_name)
  as_user(user) do
    begin_drafting_publication(title)
    click_button "Save"
    add_external_attachment
  end
end

When /^I draft a new publication "([^"]*)" that does not apply to the nations:$/ do |title, nations|
  begin_drafting_publication(title)
  nations.raw.flatten.each do |nation_name|
    within record_css_selector(Nation.find_by_name!(nation_name)) do
      check nation_name
      fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
    end
  end
  click_button "Save"
  add_external_attachment
end

When /^I draft a new publication "([^"]*)" relating it to the policies "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_publication(title)
  select first_policy, from: "Policies"
  select second_policy, from: "Policies"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" referencing the data set "([^"]*)"$/ do |title, data_set_name|
  begin_drafting_publication(title)
  select data_set_name, from: "Related statistical data sets"
  click_button "Save"
  add_external_attachment
end

Then /^I should see in the preview that "([^"]*)" is taken from the live data in "([^"]*)"$/ do |title, data_set_name|
  publish(force: true)
  click_on title
  click_on "View on website"
  assert has_css?(".meta a", text: data_set_name, exact: false)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?("a[href*='#{@attachment.filename}']")
end

Then /^I should see a thumbnail of the first page of the PDF$/ do
  assert page.has_css?(".attachment img[src*='#{@attachment.filename}.png']") || page.has_css?("div.img img[src*='#{@attachment.filename}.png']")
end

Then /^I should see the summary of the publication "([^"]*)"$/ do |publication_title|
  publication = Publication.published.find_by!(title: publication_title)
  assert has_css?("#{record_css_selector(publication)} h3", publication.title)
end

Then /^I should see the summary of the draft publication "([^"]*)"$/ do |publication_title|
  publication = Publication.find_by!(title: publication_title)
  assert has_css?("h1", publication.title)
end

Then /^I should see "([^"]*)" is a corporate publication of the "([^"]*)"$/ do |title, organisation|
  visit_organisation organisation
  assert has_css?("#{corporate_publications_selector}, .publication a", text: title)
end

Then /^I should see that the publication is about "([^"]*)"$/ do |world_location_name|
  assert has_css?(".meta a", text: world_location_name)
end

Then /^I should get a "([^"]*)" error$/ do |error_code|
  assert_equal error_code.to_i, page.status_code
end

When /^I replace the data file of the attachment in a new draft of the publication$/ do
  old_edition = Publication.last
  visit edit_admin_publication_path(old_edition)
  @old_attachment_data = old_edition.attachments.first.attachment_data
  new_file = pdf_attachment
  @new_attachment_filename = File.basename(new_file)
  click_button "Create new edition"
  @new_edition = Publication.last
  click_on 'Attachments'

  within record_css_selector(@new_edition.attachments.first.becomes(Attachment)) do
    click_on 'Edit'
  end
  attach_file 'Replace file', new_file
  click_on 'Save'

  ensure_path edit_admin_publication_path(@new_edition)
  fill_in_change_note_if_required
  click_button "Save"
end

Then /^the new data file should not be public$/ do
  @new_attachment_data = @new_edition.attachments.first.attachment_data
  assert_not_equal @old_attachment_data, @new_attachment_data
  assert_equal @new_attachment_filename, @new_attachment_data.filename

  visit public_document_path(@new_edition)
  assert page.has_css?(".attachment a[href*='#{@old_attachment_data.url}']", text: @attachment.title)
  assert page.has_no_css?(".attachment a[href*='#{@new_attachment_data.url}']")
end

When(/^I published the draft edition$/) do
  visit admin_publication_path(@new_edition)
  publish(force: true)
end

Then(/^the new data file should be public$/) do
  visit public_document_path(@new_edition)

  assert page.has_no_css?(".attachment a[href*='#{@old_attachment_data.url}']")
  assert page.has_css?(".attachment a[href*='#{@new_attachment_data.url}']", text: @attachment.title)
end

Then /^the old data file should redirect to the new data file$/ do
  assert_final_path(@old_attachment_data.url, @new_attachment_data.url)
end

Given /^a published publication "([^"]*)" with type "([^"]*)"$/ do |publication_title, publication_type|
  type_id = PublicationType.all.select {|pt| pt.singular_name == publication_type }.first.id
  create(:published_publication, title: publication_title, publication_type_id: type_id)
end

Then /^I should see "([^"]*)" in the result list$/ do |title|
  assert page.has_css?(".filter-results h3", text: %r{#{title}})
end

When /^I publish a new publication called "([^"]*)"$/ do |title|
  begin_drafting_publication(title, first_published: Date.today.to_s)
  click_button "Save"
  add_external_attachment
  publish(force: true)
end

When /^I publish a new publication of the type "([^"]*)" called "([^"]*)"$/ do |publication_type, title|
  begin_drafting_publication(title, first_published: Date.today.to_s, publication_type: publication_type)
  click_button "Save"
  add_external_attachment
  publish(force: true)
end

Then /^I should not be able to publish the publication "([^"]*)"$/ do |title|
  visit_edition_admin title
  assert page.has_no_button?('Publish')
end

Given /^"([^"]*)" submits the publication "([^"]*)"$/ do |user_name, title|
  user = User.find_by(name: user_name)
  as_user(user) do
    visit_edition_admin title
    click_button "Submit for 2nd eyes"
  end
end

Then /^I should see a link to the public version of the publication "([^"]*)"$/ do |publication_title|
  publication = Publication.published.find_by!(title: publication_title)
  visit admin_edition_path(publication)
  assert_match public_document_path(publication), find("a.public_version")[:href]
end
