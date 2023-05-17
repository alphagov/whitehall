Given(/^a submitted publication "([^"]*)" with a PDF attachment$/) do |title|
  publication = create(:submitted_publication, :with_file_attachment, title:, body: "!@1")
  @attachment = publication.attachments.first
end

Given(/^a published publication "([^"]*)" with a PDF attachment$/) do |title|
  publication = create(:published_publication, :with_file_attachment, title:, body: "!@1")
  @attachment = publication.attachments.first
end

When(/^I start drafting a new publication "([^"]*)"$/) do |title|
  begin_drafting_publication(title)
  click_button "Save and continue"
  click_button "Update tags"
end

When(/^I draft a new publication "([^"]*)"$/) do |title|
  begin_drafting_publication(title)
  click_button "Save and continue"
  click_button "Update tags"
  add_external_attachment
end

Given(/^"([^"]*)" drafts a new publication "([^"]*)"$/) do |user_name, title|
  user = User.find_by(name: user_name)
  as_user(user) do
    begin_drafting_publication(title)
    click_button "Save and continue"
    click_button "Update tags"
  end
end

When(/^I draft a new publication "([^"]*)" referencing the data set "([^"]*)"$/) do |title, data_set_name|
  begin_drafting_publication(title)
  select data_set_name, from: "Statistical data sets"
  click_button "Save and continue"
  click_button "Update tags"
  add_external_attachment
end

Then(/^I should see a link to the PDF attachment$/) do
  expect(page).to have_selector("a[href*='#{@attachment.filename}']")
end

When(/^I replace the data file of the attachment in a new draft of the publication$/) do
  @old_edition = Publication.last
  visit edit_admin_publication_path(@old_edition)
  click_button "Create new edition"
  @new_edition = Publication.last
  click_on "Attachments"
  click_on "Edit", match: :first
  @new_file = pdf_attachment
  attach_file "Replace file", @new_file
  click_on "Save"

  ensure_path edit_admin_publication_path(@new_edition)
  fill_in_change_note_if_required
  apply_to_all_nations_if_required

  click_button "Save"
end

When(/^I try to publish the draft edition$/) do
  stub_publishing_api_links_with_taxons(@new_edition.content_id, %w[a-taxon-content-id])
  visit admin_publication_path(@new_edition)
  publish(force: true, ignore_errors: true)
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
  expect(find("a.govuk-link[target='_blank']")[:href]).to eq(
    "#{Whitehall.public_protocol}://#{Whitehall.public_host}/government/publications/#{publication.document.slug}",
  )
end
