
puts "Migrating HtmlAttachment govspeak to GovspeakContent instances"
HtmlAttachment.find_each do |html_attachment|
  next unless html_attachment.govspeak_content.nil?

  print '.'

  unless html_attachment.govspeak_content.present?
    govspeak_content = html_attachment
                         .build_govspeak_content(
                           body: html_attachment.attributes['body'],
                           manually_numbered_headings: html_attachment.manually_numbered_headings
                         )
    govspeak_content.save(validate: false)
  end
end
