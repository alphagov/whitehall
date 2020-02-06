Attachment
  .where.not(type: "HtmlAttachment")
  .where.not(slug: nil)
  .update_all(slug: nil)
