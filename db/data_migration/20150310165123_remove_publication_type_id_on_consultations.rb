Edition.where('type <> "Publication" AND publication_type_id IS NOT NULL').update_all(publication_type_id: nil)
