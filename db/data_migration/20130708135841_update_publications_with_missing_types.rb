require 'csv'

PUBLICATION_TYPE_TO_ID = {
  "Policy paper"          => PublicationType::PolicyPaper,
  "Independent reports"   => PublicationType::IndependentReport,
  "Transparency data"     => PublicationType::TransparencyData,
  "Guidance"              => PublicationType::Guidance,
  "National statistics"   => PublicationType::NationalStatistics,
  "Impact assessment"     => PublicationType::ImpactAssessment,
  "Research and analysis" => PublicationType::ResearchAndAnalysis,
  "Corporate reports"     => PublicationType::CorporateReport,
  "Statistics"            => PublicationType::Statistics,
  "Correspondence"        => PublicationType::Correspondence,
  "Form"                  => PublicationType::Form,
  "Consultation"          => PublicationType::Consultation
}
VALID_TYPE_KEYS = PUBLICATION_TYPE_TO_ID.keys

def find_publication_type(type)
  return false if type.blank?

  if VALID_TYPE_KEYS.include?(type)
    PUBLICATION_TYPE_TO_ID[type]
  else
    puts "WARNING: Publication type #{type} not recognised"
    false
  end
end

forced_editions = []
# Header row is: ID,Lead Organisation,Title,Pub subtype,Indicate here if duplicate and needs to be deleted (provide URL for redirect)
CSV.foreach('db/data_migration/20130708135841_update_publications_with_missing_types.csv', encoding: "UTF-8") do |row|
  id = row[0]
  type = row[3]

  edition = Edition.find(id)

  if publication_type = find_publication_type(type)
    puts "Publication (#{id}) (#{edition.state}) type being set to #{type}"
    edition.update_attribute(:publication_type_id, publication_type.id)
  else
    puts "Publication (#{id}) (#{edition.state}) type being forced to default (Guidance)"
    edition.update_attribute(:publication_type_id, PublicationType::Guidance.id)
    forced_editions << edition
  end
end

puts "Publication update complete"
puts "\nGenerating CSV of publications that have been forced to Guidance category..."

csv_output = CSV.generate do |csv|
  forced_editions.each do |edition|
    csv << [Whitehall.url_maker.admin_edition_path(edition), edition.title, edition.lead_organisations.first.name]
  end
end

puts csv_output
