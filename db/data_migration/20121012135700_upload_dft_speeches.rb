require 'csv'

data = CSV.read(__FILE__.gsub(/\.rb/, '.csv'), headers: true, encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")
data.each do |row|

  type = SpeechType.find_by_name(row['type'])
  if type.nil?
    $stderr.puts "Unable to find type '#{row['type']}' for '#{row['title']}', skipping"
    next
  end

  organisation = Organisation.find_by_name(row['organisation'])

  if organisation.nil?
    $stderr.puts "Unable to find organisation '#{row['organisation']}' for '#{row['title']}', skipping"
    next
  end
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

  minister = Person.find_by_slug(row['delivered_by'])

  if minister.nil?
    $stderr.puts "Unable to find person '#{row['delivered_by']}' for '#{row['title']}', skipping"
    next
  end

  begin
    first_published_at = if row['first published'].present?
      day, month, year = row['first published'].split "/"
      Time.zone.parse("#{year}-#{month}-#{day}")
    end
    s = Speech.new(
      speech_type: type,
      title: row['title'],
      summary: row['summary'],
      body: row['body'],
      delivered_on: first_published_at,
      creator: creator
      )
    s.related_policies = policies
    s.role_appointment = minister.current_role_appointments.first
    s.save!
    puts "Saved #{s.id}: '#{s.title}'"
  rescue => e
    $stderr.puts "Unable to save '#{row['title']}' because #{e}"
  end
end
