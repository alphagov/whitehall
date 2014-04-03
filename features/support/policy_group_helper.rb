module PolicyGroupHelper
  def upload_pdf_to_policy_group(group)
    visit edit_admin_policy_group_path(group)
    click_link 'Attachments'
    upload_new_attachment(pdf_attachment, 'A PDF attachment')
  end

  def insert_attachment_markdown_into_policy_group_description(attachment, group)
    visit edit_admin_policy_group_path(group)
    markdown = find_markdown_snippet_to_insert_attachment(attachment)
    fill_in 'Description', with: group.description.to_s + "\n\n" + markdown
    click_button 'Save'
  end

  def check_attachment_appears_on_policy_group(attachment, group)
    visit policy_group_path(group)
    assert page_has_attachment?(attachment)
  end
end

World(PolicyGroupHelper)
