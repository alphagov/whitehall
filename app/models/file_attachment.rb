class FileAttachment < Attachment
  def could_contain_viruses?
    true
  end
end
