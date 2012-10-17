require 'csv'

data = CSV.read(File.dirname(__FILE__) + '/20121012135700_upload_dft_speeches.csv', headers: true, encoding: "UTF-8")

creator = User.find_by_name!("Automatic Data Importer")

data.each do |row|
  speech = Speech.find_by_title(row['title'])
  if not speech
    $stderr.puts "Unable to find speech #{row['title']}, skipping"
    next
  end

  minister = Person.find_by_slug(row['delivered_by'])

  if minister.nil?
    $stderr.puts "Unable to find person '#{row['delivered_by']}' for '#{row['title']}', skipping"
    next
  end

  first_published_at = (
    if row['first published'].present?
      day, month, year = row['first published'].split "/"
      Time.zone.parse("#{year}-#{month}-#{day}")
    end
  )

  role_appointment_at_publication_time = minister
    .role_appointments
    .where("started_at <= ?", first_published_at)
    .where("ended_at >= ? OR ended_at IS NULL", first_published_at).first

  if role_appointment_at_publication_time.nil?
    $stderr.puts "Unable to find role for '#{row['delivered_by']}' during '#{row['first published']}', skipping"
    next
  end

  begin
    old_appointment = speech.role_appointment
    if old_appointment != role_appointment_at_publication_time
      speech.role_appointment = role_appointment_at_publication_time
      speech.save!
      puts "Updated #{speech.id} with new appointment: #{old_appointment.role.name} -> #{role_appointment_at_publication_time.role.name}"
    end
  rescue => e
    $stderr.puts "Unable to save '#{row['title']}' because #{e}"
  end
end
