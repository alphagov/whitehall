edition = Edition.where(id: 644875).first

if edition.present?
  edition.minor_change = true

  # Skip validation here, because normally editions in a superseded state cannot
  # have their minor_change field modified.
  edition.save(validate: false)
else
  "Edition #{644875} not found."
end
