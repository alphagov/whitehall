old = Organisation.find_by!(slug: 'rural-payments-agency')
new = Organisation.find_by!(slug: 'natural-england')

undo_from = DateTime.new(2018,10,2,15,40,0)
undo_upto = undo_from + 60.minutes

docs_with_lead = EditionOrganisation.where('updated_at > ?', undo_from).where('updated_at < ?', undo_upto).where(organisation: old, lead: true).map(&:edition).compact.map(&:document).uniq
docs_with_support = EditionOrganisation.where('updated_at > ?', undo_from).where('updated_at < ?', undo_upto).where(organisation: old, lead: false).map(&:edition).compact.map(&:document).uniq

docs_with_lead.each do |document|
  begin
    next if document.document_type == 'CorporateInformationPage'
    edition = document.latest_edition
    edition.read_consultation_principles = true if document.document_type == 'Consultation'
    orgs = edition.lead_organisations.to_a

    orgs << new unless orgs.include? new
    orgs.delete old

    edition.lead_organisations = orgs
    edition.save(validate: false)
    puts document.slug
  rescue StandardError => ex
    puts "#{document.slug}: #{ex.class}, #{ex.message}"
  end
end

docs_with_support.each do |document|
  begin
    next if document.document_type == 'CorporateInformationPage'
    edition = document.latest_edition
    edition.read_consultation_principles = true if document.document_type == 'Consultation'
    orgs = edition.supporting_organisations.to_a

    orgs << new unless orgs.include?(new) || edition.lead_organisations.include?(new)
    orgs.delete old

    edition.supporting_organisations = orgs
    edition.save(validate: false)
    puts document.slug
  rescue StandardError => ex
    puts "#{document.slug}: #{ex.class}, #{ex.message}"
  end
end
