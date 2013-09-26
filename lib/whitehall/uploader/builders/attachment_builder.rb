class Whitehall::Uploader::Builders::AttachmentBuilder
  def self.build(attributes, url, cache, logger, line_number)
    return nil if attributes[:title].blank? && url.blank?
    begin
      file = cache.fetch(url, line_number)
    rescue Whitehall::Uploader::AttachmentCache::RetrievalError => e
      logger.error "Unable to fetch attachment '#{url}' - #{e.to_s}", line_number
    end
    attachment_data = AttachmentData.new(file: file)
    attachment = Attachment.new(attributes.merge(attachment_data: attachment_data))
    attachment.build_attachment_source(url: url)
    attachment
  end
end
