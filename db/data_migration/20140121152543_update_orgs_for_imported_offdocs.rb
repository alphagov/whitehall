require 'pathname'
require 'csv'

def load_or_create_organisation(org_slug)
  if org = Organisation.find_by_slug(org_slug)
    org
  else
    org_data = $orgs[org_slug]

    if org_data.nil?
      puts "Missing organisation '#{org_slug}', organisation data also missing, SKIPPED"
      return
    end

    org = Organisation.new(org_data)

    unless org.valid?
      puts "Organisation data #{org_data} is not valid, because: #{org.errors.full_messages.join(', ')}, SKIPPED"
      return
    end

    org.save!
    puts "Missing organisation '#{org_slug}', created as '#{org.try(:slug)}'"
    org
  end
end

def load_document(old_url)
  if document_source = DocumentSource.find_by_url(old_url)
    document_source.document
  else
    puts "Missing document for URL '#{old_url}', SKIPPED"
    nil
  end
end

def associate_document_with_organisation(document, organisation)
  edition = document.latest_edition

  if edition.nil?
    puts "No edition for #{document.document_type} '#{document.slug}'"
    return
  end

  lead_orgs = edition.lead_organisations.order('lead_ordering, organisations.id').to_a
  lead_orgs.reject! { |o| o.slug == 'the-national-archives' }
  lead_orgs << organisation unless lead_orgs.include?(organisation)

  editorial_remark = "Associating #{document.document_type} '#{document.slug}' with lead organisations '#{lead_orgs.map(&:slug).join(', ')}'"
  puts editorial_remark

  edition.lead_organisations = lead_orgs
  edition.skip_virus_status_check = true if Rails.env.development?

  unless edition.valid?
    puts "Edition ##{edition.id} is not valid, because: #{edition.errors.full_messages.join(', ')}, SKIPPED"
    return
  end

  edition.save!
  edition.editorial_remarks.create!(author: User.find_by_name!('GDS Inside Government Team'), body: editorial_remark)
end

raise "Missing topics CSV 'tmp/closed-and-new-organisations.csv'" unless File.exist?('tmp/closed-and-new-organisations.csv')
raise "Missing topics CSV 'tmp/ORGS_to_PUBS_association.csv'" unless File.exist?('tmp/ORGS_to_PUBS_association.csv')

org_rows = CSV.parse(Pathname.new('tmp/closed-and-new-organisations.csv').read, headers: true)

$orgs = {}
org_rows.each do |row|
  govuk_status = row["Status"] == 'Pending' ? 'joining' : row["Status"].downcase

  organisation_type_key = case row["Type"]
  when 'Ad-hoc advisory group'
    'advisory_ndpb'
  when 'Tribunal non-departmental public body'
    'tribunal_ndpb'
  else
    row["Type"].downcase.tr(' ', '_')
  end

  $orgs[row["Slug"]] = {
    name: row["# Name"],
    description: row["Description"],
    organisation_type_key: organisation_type_key,
    logo_formatted_name: row["Logo formatted name"],
    govuk_status: govuk_status
  }
end

CSV.foreach('tmp/ORGS_to_PUBS_association.csv') do |(old_url, _, org_slug)|
  next if old_url == 'old_url'

  next unless document = load_document(old_url.strip)
  next unless organisation = load_or_create_organisation(org_slug)

  associate_document_with_organisation(document, organisation)
end
