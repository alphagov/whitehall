module AttachmentHelper
  def attachment_thumbnail_path
    page.find(".attachment img")[:src]
  end

  def attachment_path
    page.find(".attachment a")[:href]
  end
end

World(AttachmentHelper)
