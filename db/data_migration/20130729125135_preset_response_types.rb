puts "Setting all #{Response.count} existing responses to '#{ConsultationOutcome}' type."
Response.update_all(type: 'ConsultationOutcome')
