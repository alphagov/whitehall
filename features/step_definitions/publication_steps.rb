Given(/^a list of publications exists$/) do
  stub_organisation_homepage_in_content_store
end

Given(/^a published publication "([^"]*)" exists that is about "([^"]*)"$/) do |publication_title, world_location_name|
  world_location = WorldLocation.find_by!(name: world_location_name)
  create(:published_publication, title: publication_title, world_locations: [world_location])
end

Given(/^a submitted publication "([^"]*)" with a PDF attachment$/) do |title|
  publication = create(:submitted_publication, :with_file_attachment, title: title, body: "!@1")
  @attachment = publication.attachments.first
end

Given(/^a published publication "([^"]*)" with a PDF attachment$/) do |title|
  publication = create(:published_publication, :with_file_attachment, title: title, body: "!@1")
  @attachment = publication.attachments.first
end

When(/^I start drafting a new publication "([^"]*)"$/) do |title|
  begin_drafting_publication(title)
  click_button "Next"
  click_button "Save legacy associations"
end

When(/^I draft a new publication "([^"]*)"$/) do |title|
  begin_drafting_publication(title)
  click_button "Next"
  click_button "Save legacy associations"
  add_external_attachment
end

Given(/^"([^"]*)" drafts a new publication "([^"]*)"$/) do |user_name, title|
  user = User.find_by(name: user_name)
  as_user(user) do
    begin_drafting_publication(title)
    click_button "Next"
    click_button "Save legacy associations"
  end
end

When(/^I visit the list of publications$/) do
  stub_content_item_from_content_store_for(publications_path)
  visit homepage
  click_link "Publications"
end

When(/^I draft a new publication "([^"]*)" relating it to the policies "([^"]*)" and "([^"]*)"$/) do |title, first_policy, second_policy|
  begin_drafting_publication(title)
  click_button "Next"
  select first_policy, from: "Policies"
  select second_policy, from: "Policies"
  click_button "Save legacy associations"
end

When(/^I draft a new publication "([^"]*)" referencing the data set "([^"]*)"$/) do |title, data_set_name|
  begin_drafting_publication(title)
  select data_set_name, from: "Related statistical data sets"
  click_button "Next"
  click_button "Save legacy associations"
  add_external_attachment
end

Then(/^I should see a link to the PDF attachment$/) do
  assert page.has_css?("a[href*='#{@attachment.filename}']")
end

Then(/^I should see a thumbnail of the first page of the PDF$/) do
  assert page.has_css?(".attachment img[src*='#{@attachment.filename}.png']") || page.has_css?("div.img img[src*='#{@attachment.filename}.png']")
end

Then(/^I should see the summary of the publication "([^"]*)"$/) do |publication_title|
  publication = Publication.published.find_by!(title: publication_title)
  assert has_css?("#{record_css_selector(publication)} h3", text: publication.title)
end

Then(/^I should see the summary of the draft publication "([^"]*)"$/) do |publication_title|
  publication = Publication.find_by!(title: publication_title)
  assert has_css?("h1", text: publication.title)
end

Then(/^I should see "([^"]*)" is a corporate publication of the "([^"]*)"$/) do |title, organisation|
  visit_organisation organisation
  assert has_css?("#{corporate_publications_selector}, .publication a", text: title)
end

Then(/^I should see that the publication is about "([^"]*)"$/) do |world_location_name|
  assert has_css?(".meta a", text: world_location_name)
end

Then(/^I should get a "([^"]*)" error$/) do |error_code|
  assert_equal error_code.to_i, page.status_code
end

When(/^I replace the data file of the attachment in a new draft of the publication$/) do
  @old_edition = Publication.last
  visit edit_admin_publication_path(@old_edition)
  click_button "Create new edition"
  @new_edition = Publication.last
  click_on 'Attachments'

  within record_css_selector(@new_edition.attachments.first.becomes(Attachment)) do
    click_on 'Edit'
  end
  @new_file = pdf_attachment
  attach_file 'Replace file', @new_file
  click_on 'Save'

  ensure_path edit_admin_publication_path(@new_edition)
  fill_in_change_note_if_required
  click_button "Save"
end

Then(/^the new data file should not have replaced the old data file$/) do
  assert_equal 1, @new_edition.attachments.count

  new_attachment_data = @new_edition.attachments.first.attachment_data
  old_attachment_data = @old_edition.reload.attachments.first.attachment_data

  assert_not_equal old_attachment_data, new_attachment_data

  new_attachment_filename = File.basename(@new_file)
  assert_equal new_attachment_filename, new_attachment_data.filename
end

When(/^I published the draft edition$/) do
  visit admin_publication_path(@new_edition)
  publish(force: true)
end

Then(/^the old data file should redirect to the new data file$/) do
  new_attachment_data = @new_edition.attachments.first.attachment_data
  old_attachment_data = @old_edition.reload.attachments.first.attachment_data

  assert_final_path(old_attachment_data.url, new_attachment_data.url)
end

Given(/^a published publication "([^"]*)" with type "([^"]*)"$/) do |publication_title, publication_type|
  type_id = PublicationType.all.select { |pt| pt.singular_name == publication_type }.first.id
  create(:published_publication, title: publication_title, publication_type_id: type_id)
end

When(/^I filter the publications list by "([^"]*)"$/) do |publication_filter|
  stub_content_item_from_content_store_for(publications_path)
  filter_path_name = (publication_filter.to_s.underscore + "_path").to_sym

  if respond_to?(filter_path_name)
    stub_content_item_from_content_store_for(send(filter_path_name))
  end

  visit publications_path
  select publication_filter, from: "Publication type"
  click_on "Refresh results"
end

Then(/^I should see "([^"]*)" in the result list$/) do |title|
  assert page.has_css?(".filter-results h3", text: %r{#{title}})
end

When(/^I publish a new publication called "([^"]*)"$/) do |title|
  begin_drafting_publication(title, first_published: Date.today.to_s)
  click_button "Save"
  add_external_attachment
  publish(force: true)
end

When(/^I publish a new publication of the type "([^"]*)" called "([^"]*)"$/) do |publication_type, title|
  begin_drafting_publication(title, first_published: Date.today.to_s, publication_type: publication_type)
  click_button "Save"
  add_external_attachment
  publish(force: true)
end

Then(/^I should not be able to publish the publication "([^"]*)"$/) do |title|
  visit_edition_admin title
  assert page.has_no_button?('Publish')
end

Given(/^"([^"]*)" submits the publication "([^"]*)"$/) do |user_name, title|
  user = User.find_by(name: user_name)
  as_user(user) do
    visit_edition_admin title
    click_button "Submit for 2nd eyes"
  end
end

Then(/^I should see a link to the public version of the publication "([^"]*)"$/) do |publication_title|
  publication = Publication.published.find_by!(title: publication_title)
  visit admin_edition_path(publication)
  assert_match public_document_path(publication), find("a.public_version")[:href]
end
