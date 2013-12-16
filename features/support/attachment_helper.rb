module AttachmentHelper
  def attachment_thumbnail_path
    within record_css_selector(@attachment) do
      page.find("img")[:src]
    end
  end

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
end

World(AttachmentHelper)
