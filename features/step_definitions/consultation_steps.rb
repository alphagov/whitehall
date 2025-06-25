Given(/^a closed consultation exists$/) do
  create(:closed_consultation)
end

When(/^I draft a new "(.*?)" language consultation "(.*?)"$/) do |locale, title|
  document_options = { type: "consultation", title:, summary: "consultation-summary", alternative_format_provider: create(:alternative_format_provider), all_nation_applicablity: false }
  document_options.merge!(locale:) unless locale == "English"
  begin_drafting_document document_options
  fill_in "Link URL", with: "http://participate.com"
  fill_in "Email", with: "participate@gov.uk"

  within "#edition_opening_at" do
    fill_in_date_and_time_field(1.day.ago.to_s)
  end

  within "#edition_closing_at" do
    fill_in_date_and_time_field(6.days.from_now.to_s)
  end

  check "Does not apply to Wales"
  fill_in "edition[nation_inapplicabilities_attributes][2][alternative_url]", with: "http://www.visitwales.co.uk/"

  check "Scotland"
  click_button "Save"
end

When(/^I add an outcome to the consultation$/) do
  visit admin_consultation_path(Consultation.last)
  click_button "Create new edition"
  click_link "Final outcome"

  fill_in "Summary (required)", with: "Outcome summary"
  click_button "Save"

  upload_new_attachment(pdf_attachment, "Outcome attachment title")
end

When(/^I add public feedback to the consultation$/) do
  visit admin_consultation_path(Consultation.last)
  click_button "Create new edition"
  click_link "Public feedback"

  fill_in "Summary", with: "Feedback summary"
  click_button "Save"

  upload_new_attachment(pdf_attachment, "Feedback attachment title")
end

When(/^I save and publish the amended consultation$/) do
  consultation = Consultation.last
  stub_publishing_api_links_with_taxons(consultation.content_id, %w[a-taxon-content-id])
  ensure_path edit_admin_consultation_path(consultation)
  fill_in_change_note_if_required
  apply_to_all_nations_if_required
  click_button "Save and go to document summary"
  publish force: true
end

When(/^I mark the consultation as offsite$/) do
  check "This consultation is held on another website"
end

Then(/^the consultation can be associated with topical events$/) do
  expect(page).to have_selector("label", text: "Topical events")
end

Then(/^I can see that the consultation has been published$/) do
  expected_title = Consultation.last.title
  expected_message = "The document #{expected_title} has been published"

  expect(page).to have_selector(".gem-c-success-alert", text: expected_message)
end

And(/^I can see the primary locale for consultation "(.*?)" is "(.*?)"$/) do |title, locale_code|
  I18n.with_locale(locale_code) do
    consultation = Consultation.find_by!(title:)
    expect(locale_code).to eq(consultation.primary_locale)
  end
end

Then(/^the consultation response should have (\d+) attachments$/) do |expected_number_of_attachments|
  expect(expected_number_of_attachments.to_i).to eq(ConsultationResponse.last.attachments.count)
end

When(/^I set the order of the responses attachments to:$/) do |attachment_order|
  click_link "Reorder attachments"

  attachment_order.hashes.each do |attachment_info|
    attachment = Attachment.find_by(title: attachment_info[:title])
    fill_in "ordering[#{attachment.id}]", with: attachment_info[:order]
  end

  click_on "Update order"
end

Then(/^the responses attachments should be in the following order:$/) do |attachment_list|
  attachment_names = all("li p:first").map(&:text).map { |t| t.delete_prefix("Title:").chomp("Processing").strip }

  attachment_list.hashes.each_with_index do |attachment_info, index|
    attachment = Attachment.find_by(title: attachment_info[:title])
    expect(attachment.title).to eq(attachment_names[index])
  end
end
