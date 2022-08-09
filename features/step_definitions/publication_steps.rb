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
  click_button "Save"
end

When(/^I draft a new publication "([^"]*)"$/) do |title|
  begin_drafting_publication(title)
  click_button "Save"
  add_external_attachment
end

Given(/^"([^"]*)" drafts a new publication "([^"]*)"$/) do |user_name, title|
  user = User.find_by(name: user_name)
  as_user(user) do
    begin_drafting_publication(title)
    click_button "Save"
  end
end

When(/^I draft a new publication "([^"]*)" referencing the data set "([^"]*)"$/) do |title, data_set_name|
  begin_drafting_publication(title)
  select data_set_name, from: "Related statistical data sets"
  click_button "Save"
  add_external_attachment
end

Then(/^I should see a link to the PDF attachment$/) do
  expect(page).to have_selector("a[href*='#{@attachment.filename}']")
end

Then(/^I should see a thumbnail of the first page of the PDF$/) do
  expect(page).to have_selector(".attachment img[src*='#{@attachment.filename}.png']").or
  have_selector("div.img img[src*='#{@attachment.filename}.png']")
end

Then(/^I should see that the publication is about "([^"]*)"$/) do |world_location_name|
  expect(page).to have_selector(".meta a", text: world_location_name)
end

Then(/^I should get a "([^"]*)" error$/) do |error_code|
  expect(error_code.to_i).to eq(status_code)
end

When(/^I replace the data file of the attachment in a new draft of the publication$/) do
  @old_edition = Publication.last
  visit edit_admin_publication_path(@old_edition)
  click_button "Create new edition"
  @new_edition = Publication.last
  click_on "Attachments"

  within record_css_selector(@new_edition.attachments.first.becomes(Attachment)) do
    click_on "Edit"
  end
  @new_file = pdf_attachment
  attach_file "Replace file", @new_file
  click_on "Save"

  ensure_path edit_admin_publication_path(@new_edition)
  fill_in_change_note_if_required
  apply_to_all_nations_if_required

  click_button "Save"
end

Then(/^the new data file should not have replaced the old data file$/) do
  expect(1).to eq(@new_edition.attachments.count)

  new_attachment_data = @new_edition.attachments.first.attachment_data
  old_attachment_data = @old_edition.reload.attachments.first.attachment_data

  expect(page).to_not have_content(old_attachment_data, new_attachment_data)

  new_attachment_filename = File.basename(@new_file)
  expect(new_attachment_filename).to eq(new_attachment_data.filename)
end

When(/^I published the draft edition$/) do
  stub_publishing_api_links_with_taxons(@new_edition.content_id, %w[a-taxon-content-id])
  visit admin_publication_path(@new_edition)
  publish(force: true)
end

When(/^I try to publish the draft edition$/) do
  stub_publishing_api_links_with_taxons(@new_edition.content_id, %w[a-taxon-content-id])
  visit admin_publication_path(@new_edition)
  publish(force: true, ignore_errors: true)
end

Given(/^a published publication "([^"]*)" with type "([^"]*)"$/) do |publication_title, publication_type|
  type_id = PublicationType.all.select { |pt| pt.singular_name == publication_type }.first.id
  create(:published_publication, title: publication_title, publication_type_id: type_id)
end

When(/^I publish a new publication called "([^"]*)"$/) do |title|
  begin_drafting_publication(title, first_published: Time.zone.today.to_s)
  click_button "Save"
  add_external_attachment
  publish(force: true)
end

When(/^I publish a new publication of the type "([^"]*)" called "([^"]*)"$/) do |publication_type, title|
  begin_drafting_publication(title, first_published: Time.zone.today.to_s, publication_type: publication_type)
  click_button "Save"
  add_external_attachment
  publish(force: true)
end

Then(/^I should not be able to publish the publication "([^"]*)"$/) do |title|
  visit_edition_admin title
  expect(page).to_not have_button("Publish")
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
  expect(find("a.public_version")[:href]).to eq(
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications/#{publication.document.slug}",
  )
end
