require 'csv'

data = CSV.read(
  File.dirname(__FILE__) + '/20121029112744_upload_dclg_news.csv',
  headers: true,
  encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")
organisation = Organisation.find_by_name('Department for Communities & Local Government')
raise "Organisation not found" unless organisation

puts "ID,First published,Title,Old URL,Errors"
data.each do |row|
  errors = []

  source_url         = row['old_url']
  title              = row['Title']
  body               = row['Body']
  first_published_at = row['First published']
  policy_slugs       = [row['Policy 1'], row['Policy 2'], row['Policy 3'], row['Policy 4']]
  people_slugs       = [row['Role 1'], row['Role 2']]
  country_slugs      = [row['Country 1'], row['Country 2'], row['Country 3']]

  policies = policy_slugs.map do |slug|
    next if slug.blank?
    doc = Document.find_by_slug(slug)
    if doc
      doc.published_edition ? doc.published_edition : doc.latest_edition
    else
      errors << "Unable to find policy '#{slug}'"
      nil
    end
  end.compact.uniq

  if body.gsub! /\!\[/, '*Unsupported embedding or hotlinking* \!['
    errors << "Unsupported embedding or hotlinking"
  end

  first_published_at = if first_published_at.present?
    Time.zone.parse(first_published_at)
  end

  role_appointments = people_slugs.map do |slug|
    next if slug.blank?
    person = Person.find_by_slug(slug)
    if person
      person.role_appointments_at(first_published_at)
    else
      errors << "Unable to find person with slug '#{slug}'"
      nil
    end
  end.flatten.compact

  if country_slugs.compact.any?
    errors << "Ignoring countries as we don't know what format to expect them in"
  end

  begin
    n = NewsArticle.new(
      creator: creator,
      title: title,
      body: body,
      first_published_at: first_published_at
    )
    n.related_policies = policies
    n.organisations = [organisation]
    n.role_appointments = role_appointments
    n.save!
    DocumentSource.create!(document: n.document, url: source_url)
  rescue => e
    errors << e
  ensure
    puts [n.id || 'Unsaved', first_published_at, title, source_url, errors.join('. ')].to_csv
  end
end