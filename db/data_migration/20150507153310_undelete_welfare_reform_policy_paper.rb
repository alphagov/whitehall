edition = Publication.unscoped.find(489925)
edition.update(state: "draft")
edition.document.update(slug: edition.document.slug.gsub(/^deleted-/, ""))
