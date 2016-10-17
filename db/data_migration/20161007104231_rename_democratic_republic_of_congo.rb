old_slug = "democratic-republic-of-congo"
new_slug = "democratic-republic-of-the-congo"

WorldLocation
  .where(slug: old_slug)
  .update_all(slug: new_slug)
