def should_show_summary_title_for_generic_content_block(document_title)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
end

def should_show_summary_card_for_contact_content_block(document_title, email_address, organisation, instructions_to_publishers = nil)
  should_show_generic_content_block_details(document_title, organisation, instructions_to_publishers)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Email address")
  expect(page).to have_selector(".govuk-summary-list__value", text: email_address)
end

def should_show_summary_card_for_pension_content_block(document_title, description, organisation, instructions_to_publishers = nil)
  should_show_generic_content_block_details(document_title, organisation, instructions_to_publishers)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Description")
  expect(page).to have_selector(".govuk-summary-list__value", text: description)
end

def should_show_generic_content_block_details(document_title, organisation, instructions_to_publishers = nil)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Title")
  expect(page).to have_selector(".govuk-summary-list__value", text: document_title)
  expect(page).to have_selector(".govuk-summary-list__key", text: "Lead organisation")
  expect(page).to have_selector(".govuk-summary-list__value", text: organisation)
  if instructions_to_publishers
    expect(page).to have_selector(".govuk-summary-list__key", text: "Instructions to publishers")
    expect(page).to have_selector(".govuk-summary-list__value", text: instructions_to_publishers)
  end
  expect(page).to have_selector(".govuk-summary-list__key", text: "Status")
  expect(page).to have_selector(".govuk-summary-list__value", text: @user.name)
end

def should_show_edit_form_for_pension_content_block(content_block)
  expect(page).to have_content(I18n.t("content_block_edition.update.title", block_type: "pension"))
  expect(page).to have_field("Title", with: content_block.title)
  expect(page).to have_field("Description", with: content_block.details["description"])
  expect(page).to have_content("Save and continue")
  expect(page).to have_content("Cancel")
end

def should_show_edit_form_for_contact_content_block(content_block)
  expect(page).to have_content(I18n.t("content_block_edition.update.title", block_type: "contact"))
  expect(page).to have_field("Title", with: content_block.title)
  expect(page).to have_field("Description", with: content_block.details["description"])
  expect(page).to have_content("Save and continue")
  expect(page).to have_content("Cancel")
end

def visit_edit_page
  visit content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document)
end

def change_details(object_type: "pension")
  fill_in "Title", with: "Changed title"

  case object_type
  when "pension"
    fill_in "Description", with: "New description"
  else
    fill_in "Email address", with: "changed@example.com"
  end

  select "Ministry of Example", from: "content_block_manager_content_block_edition_lead_organisation"
  fill_in "Instructions to publishers", with: "new context information"
  click_save_and_continue
end

def click_save_and_continue
  click_on "Save and continue"
end

def schedule_change(number_of_days)
  choose "Schedule the edit for the future"
  @future_date = number_of_days.days.since(Time.zone.now)
  @is_scheduled = true
  fill_in_date_and_time_field(@future_date)

  click_on "Save and continue"
end

def publish_now
  choose "Publish the edit now"
  click_save_and_continue
end

def update_content_block
  # go to the edit page for the block
  visit content_block_manager.new_content_block_manager_content_block_document_edition_path(@content_block.document)
  #  fill in the new data
  change_details
  # accept changes if there is any dependent content
  click_save_and_continue if @dependent_content.present?
end

def add_internal_note
  @internal_note = "Some internal note goes here"
  fill_in "Explain what changes you did or did not make and why.", with: @internal_note
  click_save_and_continue
end

def add_change_note
  @change_note = "Some text"
  choose "Yes - information has been added, updated or removed"
  fill_in "Describe the edit for users", with: @change_note
  click_save_and_continue
end

def review_and_confirm
  check "is_confirmed"
  click_on @is_scheduled ? "Schedule" : "Publish"
end
