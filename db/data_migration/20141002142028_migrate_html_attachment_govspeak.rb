
puts "Migrating HtmlAttachment govspeak to GovspeakContent instances"
HtmlAttachment.find_each do |html_attachment|
  next unless html_attachment.govspeak_content.nil?

  print '.'
  govspeak_content = html_attachment.build_govspeak_content(
                      body: html_attachment.attributes['body']
                     )
  govspeak_content.save(validate: false)
end
