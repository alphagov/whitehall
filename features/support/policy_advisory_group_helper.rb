module PolicyAdvisoryGroupHelper
  def upload_pdf_to_policy_advisory_group(group)
    visit edit_admin_policy_advisory_group_path(group)
    click_link 'Attachments'
    upload_new_attachment(pdf_attachment, 'A PDF attachment')
  end

  def insert_attachment_markdown_into_policy_advisory_group_description(attachment, group)
    visit edit_admin_policy_advisory_group_path(group)
    markdown = find_markdown_snippet_to_insert_attachment(attachment)
    fill_in 'Description', with: group.description.to_s + "\n\n" + markdown
    click_button 'Save'
  end

  def find_markdown_snippet_to_insert_attachment(attachment)
    find("strong:contains('#{attachment.title}') + code").text
  end

  def check_attachment_appears_on_policy_advisory_group(attachment, group)
    visit policy_advisory_group_path(group)
    assert page.has_css?('.attachment-details .title', text: attachment.title)
  end
end

World(PolicyAdvisoryGroupHelper)
