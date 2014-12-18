module AttachmentHelper

  def attachment_path
    within record_css_selector(@attachment) do
      page.find_link(@attachment_title)[:href]
    end
  end

  def jpg_image
    Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")
  end

  def upload_new_attachment(file_path, attachment_title)
    click_link "Upload new file attachment"
    fill_in "Title", with: attachment_title
    attach_file "File", file_path
    click_button "Save"
    Attachment.find_by_title(attachment_title)
  end

  def create_external_attachment(url, attachment_title)
    click_on 'Add new external attachment'
    fill_in 'Title', with: attachment_title
    fill_in 'External url', with: url
    click_on 'Save'
    Attachment.find_by_title(attachment_title)
  end

  def add_external_attachment
    location = current_url
    click_link "Modify attachments"
    create_external_attachment('http://www.example.com/example', 'Example doc')
    visit location
  end

  def find_markdown_snippet_to_insert_attachment(attachment)
    find("strong:contains('#{attachment.title}') + code").text
  end

  def page_has_attachment?(attachment)
    page.has_css?('.attachment-details .title', text: attachment.title)
  end
end

World(AttachmentHelper)
