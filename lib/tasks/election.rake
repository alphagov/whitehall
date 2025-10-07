require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

namespace :election do
  desc "Remove MP from MP's letters"
  task remove_mp_letters: :environment do
    puts "Removing MP from MP's letters:"
    query = Person.where('letters LIKE "%MP%"')
    people_to_change = []

    puts "----------DRY RUN----------"
    query.find_each do |person|
      new_letters = person.letters.split(" ").reject { _1 == "MP" }.join(" ")
      if person.letters == new_letters
        puts "Skipped #{person.name} - includes 'MP' (case insensitive), but doesn't match exactly"
      else
        puts "Found #{person.name} that matches 'MP'"
        people_to_change << {
          id: person.id,
          old_name: person.name,
          new_letters: new_letters,
        }
      end
    end

    unless shell.yes?("Proceed with the above changes? (yes/no)")
      shell.say_error "Aborted"
      next
    end

    puts "----------CHANGES SUMMARY----------"
    people_to_change.each do |person|
      person_record = Person.find(person[:id])
      person_record.update!(letters: person[:new_letters])
      puts "Updated #{person[:old_name]} to #{person_record.name}"
    end
  end

  desc "Republish all political content"
  task republish_political_content: :environment do
    political_document_ids = Edition
      .where(political: true)
      .pluck(:document_id)
      .uniq

    unless shell.yes?("Republishing #{political_document_ids.count} documents. Proceed? (yes/no)")
      shell.say_error "Aborted"
      next
    end

    political_document_ids.each do |document_id|
      print "."
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        "bulk_republishing",
        document_id,
        true, # bulk_publishing
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
    end_date = Time.zone.today
    prime_ministerial_role_id = 1
    begin
      if args[:end_date]
        end_date = Date.parse(args[:end_date])
      end

      unless shell.yes?("You're about to end #{appointments.size} ministerial appointments (excluding the Prime Minister) with an end date of #{end_date}. Proceed? (yes/no)")
        shell.say_error "Aborted"
        next
      end

      appointments.each do |appointment|
        next if appointment.role_id == prime_ministerial_role_id

        print "."
        appointment.update!(ended_at: end_date)
      end
    rescue StandardError => e
      puts e.message
    end
  end

  desc "
  Mark all documents of a given organisation as political
    Usage:
    rake election:identify_political_content_for[organisation_slug, '30-12-2024']
    "
  task :identify_political_content_for, %i[slug date] => :environment do |_t, args|
    date = Date.parse(args[:date])
    org = Organisation.find_by!(slug: args[:slug])
    puts "Marking all documents as political for #{org.name}..."

    editions = org.editions
    published = editions.published.where("first_published_at >= ?", date)
    pre_published_editions = Edition.in_pre_publication_state.where(document_id: published.map(&:document_id))

    unless shell.yes?("You're about to update the 'political' value for #{published.size} published editions and #{pre_published_editions.size} pre-publication editions associated with #{org} since #{date}. Proceed? (yes/no)")
      shell.say_error "Aborted"
      next
    end

    published.find_each { |edition| edition.update_column(:political, PoliticalContentIdentifier.political?(edition)) }
    pre_published_editions.find_each { |edition| edition.update_column(:political, PoliticalContentIdentifier.political?(edition)) }

    puts "Done"
  rescue Date::Error => _e
    puts "The date is not on the right format [\"#{args[:date]}\"]"
  rescue ActiveRecord::RecordNotFound => _e
    puts "There is no Organisation with slug [\"#{args[:slug]}\"]"
  end
end
