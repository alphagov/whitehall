first_attachments = HtmlAttachment.where(
  content_id: "64e8921a-0363-4665-b7c9-c317185769f5",
  title: "HS220 More than one trade, profession or vocation (2017)"
)

new_content_id = SecureRandom.uuid

first_attachments.update_all(
  content_id: new_content_id,
  slug: "hs220-more-than-one-trade-profession-or-vocation-2017"
)

second_attachments = HtmlAttachment.where(
  content_id: "64e8921a-0363-4665-b7c9-c317185769f5",
  title: "HS220 More than one business (2016)"
)

second_attachments.update_all(
  slug: "hs220-more-than-one-business-2016"
)

parent_document_id = 243246

PublishingApiDocumentRepublishingWorker.new.perform(parent_document_id)
