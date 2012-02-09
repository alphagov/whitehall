Given /^a published publication "([^"]*)" exists that is about "([^"]*)"$/ do |publication_title, country_name|
  country = Country.find_by_name!(country_name)
  create(:published_publication, title: publication_title, countries: [country])
end

Given /^a draft publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = build(:attachment, file: pdf_attachment, title: "Attachment Title")
  create(:draft_publication, title: title, attachments: [attachment])
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = build(:attachment, file: pdf_attachment, title: "Attachment Title")
  create(:submitted_publication, title: title, attachments: [attachment])
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = build(:attachment, file: pdf_attachment, title: "Attachment Title")
  create(:published_publication, title: title, attachments: [attachment])
end

Given /^I attempt to create an invalid publication with an attachment$/ do
  begin_drafting_document type: "Publication", title: ""
  select_date "Publication date", with: "2010-01-01"
  file = pdf_attachment
  within ".attachments" do
    fill_in "Title", with: "Attachment Title"
    attach_file "File", file.path
  end
  click_button "Save"
end

When /^I draft a new publication "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'publication', title: title
  fill_in_publication_fields
  within ".attachments" do
    fill_in "Title", with: "Attachment Title"
    attach_file "File", Rails.root.join("features/fixtures/attachment.pdf")
  end
  check "Wales"
  fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  select policy.title, from: "Related Policies"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" that does not apply to the nations:$/ do |title, nations|
  begin_drafting_document type: 'publication', title: title
  fill_in_publication_fields
  nations.raw.flatten.each do |nation_name|
    check nation_name
    fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
  end
  click_button "Save"
end

When /^I draft a new corporate publication "([^"]*)" about the "([^"]*)"$/ do |title, organisation|
  begin_drafting_document type: 'publication', title: title
  fill_in_publication_fields
  select organisation, from: "Producing Organisations"
  check "Corporate publication?"
  click_button "Save"
end

When /^I visit the list of publications$/ do
  visit "/"
  click_link "Publications"
end

When /^I draft a new publication "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "Publication", title: title
  fill_in_publication_fields
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

When /^I remove the attachment from the publication "([^"]*)"$/ do |title|
  begin_editing_document title
  uncheck "document_document_attachments_attributes_0__destroy"
  click_button "Save"
end

When /^I remove the attachment from a new draft of the publication "([^"]*)"$/ do |title|
  begin_new_draft_document title
  uncheck "document_document_attachments_attributes_0__destroy"
  click_button "Save"
end

When /^I feature the publication "([^"]*)"$/ do |publication_title|
  publication = Publication.find_by_title!(publication_title)
  visit published_admin_documents_path(filter: 'publication')
  within record_css_selector(publication) do
    click_button "Feature"
  end
end

When /^I unfeature the publication "([^"]*)"$/ do |publication_title|
  publication = Publication.find_by_title!(publication_title)
  visit published_admin_documents_path(filter: 'publication')
  within record_css_selector(publication) do
    click_button "No longer feature"
  end
end

When /^I set the publication title to "([^"]*)" and save$/ do |title|
  fill_in "Title", with: title
  click_button "Save"
end

Then /^I should not see a link to the PDF attachment$/ do
  assert page.has_no_css?(".attachment .attachment_title", text: "Attachment Title")
  assert page.has_no_css?(".attachment a[href*='attachment.pdf']", text: "Download attachment")
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment .attachment_title", text: "Attachment Title")
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: "Attachment Title")
end

Then /^I should see a thumbnail of the first page of the PDF$/ do
  assert page.has_css?(".attachment img[src*='attachment.pdf.png']") || page.has_css?("div.img img[src*='attachment.pdf.png']")
end

Then /^I can see links to the related published publications "([^"]*)" and "([^"]*)"$/ do |publication_title_1, publication_title_2|
  publication_1 = Publication.published.find_by_title!(publication_title_1)
  publication_2 = Publication.published.find_by_title!(publication_title_2)
  assert has_css?("#{related_publications_selector} .publication a", text: publication_title_1)
  assert has_css?("#{related_publications_selector} .publication a", text: publication_title_2)
end

Then /^I should see the summary of the publication "([^"]*)"$/ do |publication_title|
  publication = Publication.published.find_by_title!(publication_title)
  assert has_css?("#{record_css_selector(publication)} .summary", publication.summary)
end

Then /^I should see "([^"]*)" is a corporate publication of the "([^"]*)"$/ do |title, organisation|
  visit_organisation organisation
  assert has_css?("#{corporate_publications_selector}, .publication a", text: title)
end

Then /^I should see that the publication is about "([^"]*)"$/ do |country_name|
  country = Country.find_by_name!(country_name)
  assert has_css?("#{metadata_nav_selector} #{record_css_selector(country)}")
end

Then /^the publication "([^"]*)" should (not )?be featured on the public publications page$/ do |publication_title, should_not_be_featured|
  visit publications_path
  publication = Publication.published.find_by_title!(publication_title)

  publication_is_featured = has_css?("#featured-publications #{record_css_selector(publication)}")
  if should_not_be_featured
    refute publication_is_featured
  else
    assert publication_is_featured
  end
end
