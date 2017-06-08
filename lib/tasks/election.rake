namespace :election do
  task remove_mp_letters: :environment do
    puts "Removing MP from MP's letters:"
    Person.where('letters LIKE "%MP%"').each do |person|
      puts "updating #{person.name}"
      new_letters = person.letters.gsub(/(^|\s)MP(\s|$)/, '')
      if person.letters != new_letters
        person.update_attribute(:letters, new_letters)
      end
      puts "changed to #{person.name}"
    end
  end

  task republish_political_content: :environment do
    political_document_ids = Edition
      .where(political: true)
      .pluck(:document_id)
      .uniq

    puts "Republishing #{political_document_ids.count} documents"

    political_document_ids.each do |document_id|
      print "."
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        "bulk_republishing",
        document_id
      )
    end
  end

  desc "
  Removes all current ministerial appointments with the exception
  of the prime minister
  Usage
    rake election:end_ministerial_appointments

    or to specify an end date other than today

    rake election:end_ministerial_appointments[2017-06-09]
  "
  task :end_ministerial_appointments, [:end_date] => :environment do |_t, args|
    appointments = RoleAppointment.current.for_ministerial_roles
    end_date = Date.today
    prime_ministerial_role_id = 1
    begin
      if args[:end_date]
        end_date = Date.parse(args[:end_date])
      end
      appointments.each do |appointment|
        next if appointment.role_id == prime_ministerial_role_id
        print "."
        appointment.update_attribute(:ended_at, end_date)
      end
    rescue StandardError => ex
      puts ex.message
    end
  end
end
