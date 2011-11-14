When /^I draft a new publication "([^"]*)"$/ do |title|
  policy = create(:policy)
  begin_drafting_document type: 'publication', title: title
  attach_file "Attachment", Rails.root.join("features/fixtures/attachment.pdf")
  check "Wales"
  fill_in "Alternative url", with: "http://www.visitwales.co.uk/"
  select policy.title, from: "Related Policies"
  click_button "Save"
end

When /^I draft a new publication "([^"]*)" that does not apply to the nations:$/ do |title, nations|
  begin_drafting_document type: 'publication', title: title
  nations.raw.flatten.each do |nation_name|
    check nation_name
    fill_in "Alternative url", with: "http://www.#{nation_name}.com/"
  end
  click_button "Save"
end

Given /^a draft publication "([^"]*)" with a PDF attachment "([^"]*)"$/ do |title, attachment_title|
  attachment = Attachment.new(file: pdf_attachment(attachment_title))
  create(:draft_publication, title: title, attachments: [attachment])
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(file: pdf_attachment)
  create(:submitted_publication, title: title, attachments: [attachment])
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(file: pdf_attachment)
  create(:published_publication, title: title, attachments: [attachment])
end

Given /^a published publication "([^"]*)" with a PDF attachment "([^"]*)"$/ do |title, attachment_title|
  attachment = Attachment.new(file: pdf_attachment(attachment_title))
  create(:published_publication, title: title, attachments: [attachment])
end

When /^I draft a new publication "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "Publication", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

When /^I remove the attachment "([^"]*)" from the publication "([^"]*)"$/ do |attachment, title|
  begin_editing_document title
  uncheck "document_document_attachments_attributes_0__destroy"
  click_button "Save"
end

When /^I remove the attachment "([^"]*)" from a new draft of the publication "([^"]*)"$/ do |attachment, title|
  begin_new_draft_document title
  uncheck "document_document_attachments_attributes_0__destroy"
  click_button "Save"
end

Then /^I should not see a link to the PDF attachment "([^"]*)"$/ do |name|
  assert page.has_no_css?(".attachment a[href*='#{name}']", text: name)
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: "attachment.pdf")
end

Then /^I should see a link to the PDF attachment "([^"]*)"$/ do |name|
  assert page.has_css?(".attachment a[href*='#{name}']", text: name)
end

Then /^I can see links to the related published publications "([^"]*)" and "([^"]*)"$/ do |publication_title_1, publication_title_2|
  publication_1 = Publication.published.find_by_title!(publication_title_1)
  publication_2 = Publication.published.find_by_title!(publication_title_2)
  assert has_css?("#{related_publications_selector} .publication a", text: publication_title_1)
  assert has_css?("#{related_publications_selector} .publication a", text: publication_title_2)
end

def pdf_attachment(filename=nil)
  fixture_path = Rails.root.join("features/fixtures/attachment.pdf")
  if filename
    path = File.join(Dir.tmpdir, filename)
    File.open(path, "w") { |f| f.write filename }
    File.open(path)
  else
    File.open(fixture_path)
  end
end

