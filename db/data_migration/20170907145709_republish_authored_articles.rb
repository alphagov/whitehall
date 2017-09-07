type = SpeechType.all.detect { |t| t.key == "authored_article" }

document_ids = Speech
  .published
  .where(speech_type_id: type.id)
  .pluck(:document_id)
  .uniq

document_ids.each do |id|
  PublishingApiDocumentRepublishingWorker.perform_async_in_queue("bulk_republishing", id)
  print "."
end
