puts "Regenerating HtmlAttachment govspeak content"
govspeak_content_worker = GovspeakContentWorker.new
HtmlAttachment.find_each do |html_attachment|
  if html_attachment.govspeak_content
    begin
      govspeak_content_worker.perform(html_attachment.govspeak_content.id)
     rescue Exception => e
       puts "Error processing Attachment #{html_attachment.id}"
       puts e
     end
  end
end
