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

Given /^"([^"]*)" has received an email requesting they fact check a draft publication "([^"]*)"$/ do |email, title|
  publication = create(:draft_publication, title: title)
  fact_check_request = publication.fact_check_requests.create(email_address: email)
  Notifications.fact_check(fact_check_request, create(:user), host: "example.com").deliver
end

Given /^a submitted publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(file: File.open(pdf_attachment))
  create(:submitted_publication, title: title, attachment: attachment)
end

Given /^a published publication "([^"]*)" with a PDF attachment$/ do |title|
  attachment = Attachment.new(file: File.open(pdf_attachment))
  create(:published_publication, title: title, attachment: attachment)
end

When /^I draft a new publication "([^"]*)" relating it to "([^"]*)" and "([^"]*)"$/ do |title, first_policy, second_policy|
  begin_drafting_document type: "Publication", title: title
  select first_policy, from: "Related Policies"
  select second_policy, from: "Related Policies"
  click_button "Save"
end

Then /^I should see a link to the PDF attachment$/ do
  assert page.has_css?(".attachment a[href*='attachment.pdf']", text: /^attachment\.pdf$/)
end

Then /^I can see links to the related published publications "([^"]*)" and "([^"]*)"$/ do |publication_title_1, publication_title_2|
  publication_1 = Publication.published.find_by_title(publication_title_1)
  publication_2 = Publication.published.find_by_title(publication_title_2)
  assert has_css?("#related-publications .publication a", text: publication_title_1)
  assert has_css?("#related-publications .publication a", text: publication_title_2)
end

def pdf_attachment
  Rails.root.join("features/fixtures/attachment.pdf")
end

