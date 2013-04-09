module AttachmentHelper
  def attachment_thumbnail_path
    page.find(".attachment img")[:src]
  end

  def attachment_path
    page.find(".attachment a")[:href]
  end

  def jpg_image
    Rails.root.join("test/fixtures/minister-of-funk.960x640.jpg")
  end
end

World(AttachmentHelper)
