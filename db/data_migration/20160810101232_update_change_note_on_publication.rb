edition_id = 644875
edition = Edition.where(id: edition_id).first

if edition.present?
  edition.minor_change = true

  # Skip validation here, because normally editions in a superseded state cannot
  # have their minor_change field modified.
  edition.save(validate: false)
else
  "Edition #{edition_id} not found."
end
