HtmlAttachment.where(slug: nil).find_each do |html_attachment|
  html_attachment.update_column(:slug, html_attachment.id.to_s)
end
