module CorporateInformationPageHelper
  def upload_pdf_to_corporate_information_page(page)
    visit admin_organisation_path(page.organisation)
    click_link 'Corporate information pages'
    click_link page.title
    save_page
    click_link 'Modify attachments'
    upload_new_attachment(pdf_attachment, 'A PDF attachment')
  end

  def insert_attachment_markdown_into_corporate_information_page_body(attachment, page)
    visit admin_organisation_path(page.organisation)
    click_link 'Corporate information pages'
    click_link page.title
    click_link 'Edit draft'
    markdown = find_markdown_snippet_to_insert_attachment(attachment)
    fill_in 'Body', with: page.body.to_s + "\n\n" + markdown
    click_button 'Save'
  end

  def check_attachment_appears_on_corporate_information_page(attachment, page)
    visit organisation_path(page.organisation)
    click_link page.title
    assert page_has_attachment?(attachment)
  end
end

World(CorporateInformationPageHelper)
