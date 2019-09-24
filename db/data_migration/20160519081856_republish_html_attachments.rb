published_edition_ids = Edition.where("state IN('published', 'withdrawn')")
  .joins("INNER JOIN attachments ON attachable_id = editions.id
          AND attachable_type = 'Edition'
          AND attachments.type = 'HtmlAttachment'")
  .pluck("editions.id")

draft_edition_ids = Edition.where(state: "draft")
  .joins("INNER JOIN attachments ON attachable_id = editions.id
          AND attachable_type = 'Edition'
          AND attachments.type = 'HtmlAttachment'")
  .pluck("editions.id")

HtmlAttachment.where(attachable_type: "Edition", attachable_id: published_edition_ids).find_each do |a|
  Whitehall::PublishingApi.publish_async(a, "republish", "bulk_republishing")
end

HtmlAttachment.where(attachable_type: "Edition", attachable_id: draft_edition_ids).find_each do |a|
  Whitehall::PublishingApi.save_draft_async(a, "republish", "bulk_republishing")
end
