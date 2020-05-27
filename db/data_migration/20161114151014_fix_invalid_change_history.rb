edition = Edition.find(394_423)
edition.change_note = "Document updated"
edition.save!(validate: false)
