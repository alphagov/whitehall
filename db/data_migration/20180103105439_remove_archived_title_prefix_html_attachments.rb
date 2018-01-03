HtmlAttachment.where("title like '[%'").each do |attachment|
  id = attachment.id

  old_title = attachment.title
  new_title = old_title.sub(/^\[archived?\]\s*/i, "")

  raise "Title should have changed for id=#{id}" if old_title == new_title

  puts "id=#{id}: #{old_title} -> #{new_title}"
  next if ENV["DRY_RUN"]

  attachable = attachment.attachable
  document = attachable.document

  print "  Removing from search index..."
  Whitehall::SearchIndex.delete(attachable)
  puts "Done."

  print "  Updating title..."
  attachment.title = new_title
  attachment.save!(validate: false)
  puts "Done."

  print "  Republishing... "
  PublishingApiDocumentRepublishingWorker.new.perform(document.id)
  puts "Done."

  print "  Re-adding to search index..."
  Whitehall::SearchIndex.add(attachable.reload)
  puts "Done."
end
