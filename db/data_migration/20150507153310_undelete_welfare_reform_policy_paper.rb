edition = Publication.unscoped.find(489_925)
edition.update!(state: "draft")
edition.document.update!(slug: edition.document.slug.gsub(/^deleted-/, ""))
