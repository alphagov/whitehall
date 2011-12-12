module AttachmentsHelper
  def css_class_for_attachment(attachment)
    classes = ["attachment"]
    classes << "pdf" if attachment.pdf?
    classes.join(" ")
  end
end