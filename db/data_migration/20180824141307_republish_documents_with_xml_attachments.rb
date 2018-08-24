document_ids = Document.joins(:editions)
  .joins("INNER JOIN attachments ON editions.id = attachments.attachable_id
          AND attachments.attachable_type = 'Edition'")
  .joins("INNER JOIN attachment_data ON attachments.attachment_data_id = attachment_data.id")
  .where("editions.state = 'published'")
  .where("attachment_data.carrierwave_file like '%.xml'")
  .pluck(:id).uniq

  document_ids.each do | document_id |
    PublishingApiDocumentRepublishingWorker.perform_async(document_id)
  end
