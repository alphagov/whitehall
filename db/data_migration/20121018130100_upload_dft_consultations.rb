require 'csv'

data = CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8")

puts data.headers.join("\n")

creator = User.find_by_name!("Automatic Data Importer")
data.each do |row|
  opening_date = Date.strptime(row['opening_date'], "%m/%d/%Y")
  closing_date = Date.strptime(row['closing_date'], "%m/%d/%Y")

  case row['title']
    when 'Electrically assisted pedal cycles consultation'
      opening_date = Date.parse("2010-01-05")
    when 'Amending driving licence standards for vision, diabetes and epilepsy'
      opening_date, closing_date = Date.parse('2011-02-03'), Date.parse('2011-04-28')
    when 'InterCity west coast consultation'
      opening_date = Date.parse('2011-01-19')
  end

  participation = ConsultationParticipation.new(
    link_url: row['respond url'],
    email: row['respond email'],
    postal_address: row['postal address']
  )

  policy_slugs = [row['policy 1'], row['policy 2'], row['policy 3'], row['policy 4']]
  policies = policy_slugs.map do |slug|
    next if slug.blank?
    doc = Document.find_by_slug(slug)
    if doc
      doc.published_edition
    else
      $stderr.puts "Unable to find policy '#{slug}' for '#{row['title']}'"
      nil
    end
  end.compact

  organisation = Organisation.find_by_name(row['organisation'])

  if organisation.nil?
    $stderr.puts "Unable to find organisation '#{row['organisation']}' for '#{row['title']}', skipping"
    next
  end

  role_slugs = [row['Minister 1'], row['Minister 2']].reject(&:blank?)
  roles = role_slugs.map do |slug|
    next if slug.blank?
    role = MinisterialRole.find_by_slug(slug)
    if role
      role
    else
      $stderr.puts "Unable to find role with slug '#{slug}' for '#{row['Title']}'"
      nil
    end
  end.compact

  response_summary = row['response summary (OPTIONAL)']
  response = nil
  if response_summary.present?
    response_date = Date.strptime(row['response date'], "%m/%d/%Y")
    response = Response.new(summary: response_summary, published_on: response_date)
  end

  begin
    consultation = Consultation.new(
      title: row['title'],
      summary: row['summary'],
      body: row['body'],
      opening_on: opening_date,
      closing_on: closing_date,
      consultation_participation: participation,
      related_policies: policies,
      organisations: [organisation],
      ministerial_roles: roles,
      response: response,
      first_published_at: opening_date,
      creator: creator
    )

    consultation.save!
    puts "Saved #{consultation.id}: '#{consultation.title}'"
  rescue => e
    $stderr.puts "Unable to save '#{row['title']}' because #{e}"
  end
end
