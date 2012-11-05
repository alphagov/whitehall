require 'csv'

data = CSV.read(
  File.dirname(__FILE__) + '/20121031105330_upload_dclg_speeches.csv',
  headers: true,
  encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")
puts "ID,First published,Title,Old URL,Errors"
data.each do |row|
  errors = []

  default_speech_type = SpeechType::DraftText

  source_url         = row['old_url']
  title              = row['title']
  body               = row['body']
  delivered_by_slug  = row['delivered_by']
  location           = row['event_and_location']
  speech_type_slug   = row['type']
  first_published_at = row['first_published']
  delivered_on       = row['delivered_on']
  policy_slugs       = [row['policy_1'], row['policy_2'], row['policy_3'], row['policy_4']]
  minister_slugs     = [row['minister_1'], row['minister_2']]
  country_slugs      = [row['country_1'], row['country_2'], row['country_3']]
  organisation_slug  = row['organisation']

  if body.gsub! /\!\[/, '*Unsupported embedding or hotlinking* \!['
    errors << "Unsupported embedding or hotlinking"
  end

  speech_type = SpeechType.find_by_slug(speech_type_slug)
  if speech_type.nil?
    errors << "Unable to find speech type '#{speech_type_slug}', defaulting to '#{default_speech_type.name}'"
    speech_type = default_speech_type
  end

  first_published_at = if first_published_at.present?
    Time.zone.parse(first_published_at)
  end

  delivered_on = if delivered_on.present?
    Time.zone.parse(delivered_on)
  end

  if !first_published_at && !delivered_on
    errors << "Neither first_published_at or delivered_on were found"
  elsif !first_published_at && delivered_on
    first_published_at = delivered_on
  elsif !delivered_on && first_published_at
    delivered_on = first_published_at
  end

  delivered_by = Person.find_by_slug(delivered_by_slug)
  if delivered_by.nil?
    errors << "Unable to find person '#{delivered_by_slug}'"
  end

  delivered_by_role_appointment = if delivered_by
    delivered_by.role_appointments_at(first_published_at).first
  end

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

  if minister_slugs.compact != [delivered_by_slug]
    errors << "Different data in minister slugs and delivered by slug"
  end

  if country_slugs.compact.any?
    errors << "Ignoring countries as we don't know what format to expect them in"
  end

  organisation = Organisation.find_by_slug(organisation_slug)
  if organisation.nil?
    errors << "Unable to find organisation '#{organisation_slug}'"
  end

  begin
    s = Speech.new(
      creator: creator,
      title: title,
      body: body,
      speech_type: speech_type,
      role_appointment: delivered_by_role_appointment,
      delivered_on: delivered_on,
      location: location,
      related_policies: policies,
      first_published_at: first_published_at
    )
    s.save!
    DocumentSource.create!(document: s.document, url: source_url)
  rescue => e
    errors << e
  ensure
    puts [s.id || 'Unsaved', first_published_at, title, source_url, errors.join('. ')].to_csv
  end
end
