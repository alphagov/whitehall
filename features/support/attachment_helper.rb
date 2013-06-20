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
end

World(AttachmentHelper)
