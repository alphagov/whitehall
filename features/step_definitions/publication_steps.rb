Given /^a published publication "([^"]*)" exists that is about "([^"]*)"$/ do |publication_title, world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  create(:published_publication, title: publication_title, world_locations: [world_location])
end

Given /^a draft publication "([^"]*)" with a PDF attachment$/ do |title|
  publication = create(:draft_publication, :with_attachment, title: title, body:"!@1")
  @attachment_title = publication.attachments.first.title
  @attachment_filename = publication.attachments.first.filename
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  publication = create(:submitted_publication, :with_attachment, title: title, body: "!@1")
  @attachment_title = publication.attachments.first.title
  @attachment_filename = publication.attachments.first.filename
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  publication = create(:published_publication, :with_attachment, title: title, body: "!@1")
  @attachment = publication.attachments.first
  @attachment_title = @attachment.title
  @attachment_filename = @attachment.filename
end

Given /^I attempt to create an invalid publication with an attachment$/ do
  begin_drafting_publication("")
  @attachment_title = "Attachment Title"
  @attachment_file = pdf_attachment
  within ".attachments" do
    choose "Individual upload"
    fill_in "Title", with: @attachment_title
    attach_file "File", @attachment_file
  end
  click_button "Save"
end

When /^I begin drafting a new publication "([^"]*)"$/ do |title|
  begin_drafting_publication(title)
end

When /^I draft a new publication "([^"]*)"$/ do |title|
  begin_drafting_publication(title)
  click_button "Save"
end

Given /^"([^"]*)" drafts a new publication "([^"]*)"$/ do |user_name, title|
  user = User.find_by_name(user_name)
  as_user(user) do
    begin_drafting_publication(title)
    click_button "Save"
  end
end

Given /^a published publication "([^"]*)" for the organisation "([^"]*)"$/ do |title, organisation|
  organisation = create(:organisation, name: organisation)
  create(:published_publication, title: title, organisations: [organisation])
end

Given /^(\d+) published publications for the organisation "([^"]+)"$/ do |count, organisation|
  organisation = create(:organisation, name: organisation)
  count.to_i.times { |i| create(:published_publication, title: "keyword-#{i}", organisations: [organisation]) }
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
end

When /^I visit the list of publications$/ do
  visit homepage
  click_link "Publications"
end

When /^I draft a new publication "([^"]*)" relating it to the policies "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_publication(title)
  select first_policy, from: "Related policies"
  select second_policy, from: "Related policies"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" relating it to the worldwide_priorities "([^"]*)" and "([^"]*)"$/ do |title, first_priority, second_priority|
  begin_drafting_publication(title)
  select first_priority, from: "Worldwide priorities"
  select second_priority, from: "Worldwide priorities"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" referencing the data set "([^"]*)"$/ do |title, data_set_name|
  begin_drafting_publication(title)
  select data_set_name, from: "Related statistical data sets"
  click_button "Save"
end

Then /^I should see in the preview that "([^"]*)" is taken from the live data in "([^"]*)"$/ do |title, data_set_name|
  publish(force: true)
  click_on title
  click_on "View"
  assert has_css?(".live-data a", text: data_set_name)
end

When /^I remove the attachment from the publication "([^"]*)"$/ do |title|
  begin_editing_document title
  choose "Remove"
  click_button "Save"
end

When /^I remove the attachment from a new draft of the publication "([^"]*)"$/ do |title|
  begin_new_draft_document title
  choose "Remove"
  click_button "Save"
end

When /^I correct the invalid information for the publication$/ do
  fill_in :edition_title, with: "Validation error fixed"
  fill_in :edition_body, with: "!@1"
  click_button "Save"
end

Then /^I should not see a link to the PDF attachment$/ do
  assert page.has_no_css?(".attachment .title", text: @attachment_title)
  assert page.has_no_css?(".attachment a[href*='#{@attachment_filename}']", text: "Download attachment")
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='#{@attachment_filename}']", text: @attachment_title)
end

Then /^I should see a thumbnail of the first page of the PDF$/ do
  assert page.has_css?(".attachment img[src*='#{@attachment_filename}.png']") || page.has_css?("div.img img[src*='#{@attachment_filename}.png']")
end

Then /^I should see the summary of the publication "([^"]*)"$/ do |publication_title|
  publication = Publication.published.find_by_title!(publication_title)
  assert has_css?("#{record_css_selector(publication)} h3", publication.title)
end

Then /^I should see the summary of the draft publication "([^"]*)"$/ do |publication_title|
  publication = Publication.find_by_title!(publication_title)
  assert has_css?("h1", publication.title)
end

Then /^I should see "([^"]*)" is a corporate publication of the "([^"]*)"$/ do |title, organisation|
  visit_organisation organisation
  assert has_css?("#{corporate_publications_selector}, .publication a", text: title)
end

Then /^I should see that the publication is about "([^"]*)"$/ do |world_location_name|
  world_location = WorldLocation.find_by_name!(world_location_name)
  assert has_css?(".document-world-locations #{record_css_selector(world_location)}")
end

Then /^I should get a "([^"]*)" error$/ do |error_code|
  assert_equal error_code.to_i, page.status_code
end

When /^I update the attachment metadata from a new draft of the publication$/ do
  visit edit_admin_publication_path(Publication.last)
  click_button "Create new edition"
  within "#edition_attachment_fields" do
    choose "Individual upload"
    within 'div.well:first-child' do
      fill_in "Title", with: "changed title not to be published yet"
    end
  end
  fill_in_change_note_if_required
  click_button "Save"
end

Then /^the metadata changes should not be public until the draft is published$/ do
  click_link("Preview")
  assert page.has_css?(".attachment-details .title", text: "changed title not to be published yet")
  refute page.has_css?(".attachment-details .title", text: @attachment_title)
  visit public_document_path(Publication.last)
  assert page.has_css?(".attachment-details .title", text: @attachment_title)
  refute page.has_css?(".attachment-details .title", text: "changed title not to be published yet")
end

When /^I replace the data file of the attachment in a new draft of the publication$/ do
  pub = Publication.last
  visit edit_admin_publication_path(pub)
  @old_attachment_data = pub.attachments.first.attachment_data
  new_file = pdf_attachment
  @new_attachment_filename = File.basename(new_file)
  click_button "Create new edition"
  within "#edition_attachment_fields" do
    choose "Individual upload"
    choose 'Replace'
    attach_file 'Replacement', new_file
  end
  fill_in_change_note_if_required
  click_button "Save"
end

Then /^the new data file should not be public until the draft is published$/ do
  pub = Publication.last
  @new_attachment_data = pub.attachments.first.attachment_data
  assert_not_equal @old_attachment_data, @new_attachment_data
  assert_equal @new_attachment_filename, @new_attachment_data.filename

  visit public_document_path(pub)
  assert page.has_css?(".attachment a[href*='#{@old_attachment_data.url}']", text: @attachment_title)
  assert page.has_no_css?(".attachment a[href*='#{@new_attachment_data.url}']")

  visit admin_publication_path(pub)
  publish(force: true)

  visit public_document_path(pub)

  assert page.has_no_css?(".attachment a[href*='#{@old_attachment_data.url}']")
  assert page.has_css?(".attachment a[href*='#{@new_attachment_data.url}']", text: @attachment_title)
end

Then /^the old data file should redirect to the new data file$/ do
  assert_final_path(@old_attachment_data.url, @new_attachment_data.url)
end

Given /^a published publication "([^"]*)" with type "([^"]*)"$/ do |publication_title, publication_type|
  type_id = PublicationType.all.select{|pt| pt.singular_name == publication_type }.first.id
  create(:published_publication, title: publication_title, publication_type_id: type_id)
end

When /^I filter the publications list by "([^"]*)"$/ do |publication_filter|
  visit publications_path
  select publication_filter, from: "Publication type"
  click_on "Refresh results"
end

Then /^I should see "([^"]*)" in the result list$/ do |title|
  assert page.has_css?(".filter-results h3", text: %r{#{title}})
end
