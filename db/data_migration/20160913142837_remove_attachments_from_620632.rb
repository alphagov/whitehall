edition = Edition.find(620632)
edition.attachments.map(&:delete)
