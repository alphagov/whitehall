def should_show_summary_card_for_email_address_content_block(document_title, email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
end

def should_show_summary_list_for_email_address_content_block(document_title, email_address, organisation, instructions_to_publishers = nil)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__actions", text: "Edit")
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Lead organisation")
  expect(page).to have_selector(".govuk-summary-list__value", text: organisation)
  if instructions_to_publishers
    expect(page).to have_selector(".govuk-summary-list__key", text: "Instructions to publishers")
    expect(page).to have_selector(".govuk-summary-list__value", text: instructions_to_publishers)
  end
  expect(page).to have_selector(".govuk-summary-list__key", text: "Status")
  expect(page).to have_selector(".govuk-summary-list__value", text: @user.name)
end

def should_show_edit_form_for_email_address_content_block(document_title, email_address)
  expect(page).to have_content(I18n.t("content_block_edition.update.title", block_type: "email address"))
  expect(page).to have_field("Title", with: document_title)
  expect(page).to have_field("Email address", with: email_address)
  expect(page).to have_content("Save and continue")
  expect(page).to have_content("Cancel")
end

def visit_edit_page
  visit content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document)
end

def change_details
  fill_in "Title", with: "Changed title"
  fill_in "Email address", with: "changed@example.com"
  select "Ministry of Example", from: "content_block_manager_content_block_edition_lead_organisation"
  fill_in "Instructions to publishers", with: "new context information"
  click_save_and_continue
end

def click_save_and_continue
  click_on "Save and continue"
end

def has_support_button
  expect(page).to have_link(
    "Raise a support request",
    href: Whitehall.support_url,
  )
end
