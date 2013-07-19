creator = User.find_by_name!("Automatic Data Importer")
PaperTrail.whodunnit = creator

invalid_organisations = Organisation.all.reject(&:valid?)
organisations_with_contact_email_problem = invalid_organisations.select { |o| o.errors[:alternative_format_contact_email].any? }
organisations_with_contact_email_problem.each do |organisation|
  $stderr.puts "Making organisation '#{organisation.name}' valid..."
  Edition.where(alternative_format_provider_id: organisation.id).each do |edition|
    $stderr.print "  Setting alternative format provider for edition #{edition.id}' to nil..."
    edition.update_column(:alternative_format_provider_id, nil)
    $stderr.puts "[done]"
  end
  $stderr.puts "[done]"
end
