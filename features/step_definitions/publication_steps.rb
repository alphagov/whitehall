Given /^a published publication "([^"]*)" exists that is about "([^"]*)"$/ do |publication_title, country_name|
  country = Country.find_by_name!(country_name)
  create(:published_publication, title: publication_title, countries: [country])
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
  @attachment_title = publication.attachments.first.title
  @attachment_filename = publication.attachments.first.filename
end

Given /^I attempt to create an invalid publication with an attachment$/ do
  begin_drafting_publication("")
  file = pdf_attachment
  @attachment_title = "Attachment Title"
  @attachment_file = File.basename(file.path)
  within ".attachments" do
    fill_in "Title", with: @attachment_title
    attach_file "File", file.path
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
    check nation_name
    fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
  end
  click_button "Save"
end

When /^I visit the list of publications$/ do
  visit "/"
  click_link "Publications"
end

When /^I draft a new publication "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_publication(title)
  select first_policy, from: "Related policies"
  select second_policy, from: "Related policies"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" in the "([^"]*)" collection$/ do |title, collection|
  begin_drafting_publication(title)
  select collection, from: "Collection"
  click_button "Save"
end

When /^I remove the attachment from the publication "([^"]*)"$/ do |title|
  begin_editing_document title
  uncheck "edition_edition_attachments_attributes_0__destroy"
  click_button "Save"
end

When /^I remove the attachment from a new draft of the publication "([^"]*)"$/ do |title|
  begin_new_draft_document title
  uncheck "edition_edition_attachments_attributes_0__destroy"
  click_button "Save"
end

When /^I correct the invalid information for the publication$/ do
  fill_in "Title", with: "Validation error fixed"
  fill_in "Body", with: "!@1"
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
  assert has_css?("#{record_css_selector(publication)} .title", publication.title)
end

Then /^I should see the summary of the draft publication "([^"]*)"$/ do |publication_title|
  publication = Publication.find_by_title!(publication_title)
  assert has_css?("h1 .topic", publication.title)
end

Then /^I should see "([^"]*)" is a corporate publication of the "([^"]*)"$/ do |title, organisation|
  visit_organisation organisation
  assert has_css?("#{corporate_publications_selector}, .publication a", text: title)
end

Then /^I should see that the publication is about "([^"]*)"$/ do |country_name|
  country = Country.find_by_name!(country_name)
  assert has_css?(".document-countries #{record_css_selector(country)}")
end

Then /^I should get a "([^"]*)" error$/ do |error_code|
  assert_equal error_code.to_i, page.status_code
end
