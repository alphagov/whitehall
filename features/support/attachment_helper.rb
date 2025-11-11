module AttachmentHelper
  def attachment_path
    within record_css_selector(@attachment) do
      find_link(@attachment_title)[:href]
    end
  end

  def jpg_image
    Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")
  end

  def upload_new_attachment(file_path, attachment_title)
    page.attach_file file_path
    click_button "Upload"
    fill_in "Title", with: attachment_title
    click_button "Save"
    Attachment.find_by(title: attachment_title)
  end

  def create_external_attachment(url, attachment_title)
    click_on "Add new external attachment"
    fill_in "Title", with: attachment_title
    fill_in "External url", with: url
    click_on "Save"
    Attachment.find_by(title: attachment_title)
  end

  def add_external_attachment
    location = current_url
    click_link "Add attachment"
    create_external_attachment("http://www.example.com/example", "Example doc")
    visit location
  end
end

World(AttachmentHelper)
