require 'csv'
require 'date'
require 'time'
require 'slop'

opts = Slop.parse(help: true) do
  banner "Usage: organisation_edition_report.rb [options] <org acronym or name>"
  on 'no-bom', 'Suppress unicode byte order mark (bom is recommended for MS Excel compatability).'
end

if ARGV.size != 1
  puts opts
  exit(1)
end

org_name_or_acronym = ARGV[0]

organisation = Organisation.find_by_acronym(org_name_or_acronym) || Organisation.find_by_name(org_name_or_acronym)

unless organisation
  $stderr.puts "Error: #{error}\n\n"
  puts opts
  exit(1)
end

if ! opts['no-bom']
  puts "\uFEFF"
end

url_maker = Whitehall.url_maker

fields = <<FIELDS
public url
admin url
imported from url 1
imported from url 2
type
display type
public timestamp
force published?
major version
minor version
minor change?
change note
authors
title
FIELDS
fields = fields.split("\n").compact
puts fields.to_csv
organisation.editions.includes(:document).published.find_each do |edition|
  source1, source2 = edition.document && edition.document.document_sources
  puts [
    "https://www.gov.uk" + url_maker.public_document_path(edition),
    "https://whitehall-admin.production.alphagov.co.uk" + url_maker.admin_edition_path(edition),
    source1 && source1.url,
    source2 && source2.url,
    edition.type,
    edition.display_type,
    edition.public_timestamp,
    edition.force_published?,
    edition.published_major_version,
    edition.published_minor_version,
    edition.minor_change,
    edition.change_note,
    edition.authors.uniq.map(&:name).join(", "),
    edition.title
  ].to_csv
end
