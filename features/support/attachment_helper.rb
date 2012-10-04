module AttachmentHelper
  def attachment_thumbnail_path
    page.find(".attachment img")[:src]
  end

  def attachment_path
    page.find(".attachment a")[:href]
  end

  def assert_final_path(path, expected)
    previous_location = page.current_path
    visit path
    page.current_path.should match(expected)
    visit previous_location
  end
end

World(AttachmentHelper)
