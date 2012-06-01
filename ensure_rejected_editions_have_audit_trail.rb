pete_herlihy = User.find_by_email("peter.herlihy@digital.cabinet-office.gov.uk")
PaperTrail.whodunnit = pete_herlihy

def generate_audit_trail_for_rejection(edition)
  rejected_at = edition.updated_at
  puts "Generating audit trail for rejection at #{rejected_at} for edition ID: #{edition.id}; title: #{edition.title}"
  edition.update_attributes!(state: "submitted")
  edition.updated_at = rejected_at
  edition.reject!
end

Whitehall::Application.config.active_record.record_timestamps = false

Edition.rejected.each do |edition|
  unless edition.rejected_by.present?
    generate_audit_trail_for_rejection(edition)
  end
end
