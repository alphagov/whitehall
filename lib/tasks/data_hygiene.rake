require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

namespace :data_hygiene do
  desc "Merge people records - Dry run"
  task :merge_people_dry_run, %i[person_to_merge person_to_keep] => :environment do |_task, args|
    begin
      person_to_merge = Person.find(args[:person_to_merge])
      person_to_keep = Person.find(args[:person_to_keep])
    rescue ActiveRecord::RecordNotFound
      puts "Please provide valid person IDs to merge."
      next
    end

    if person_to_merge == person_to_keep
      puts "The person IDs provided are the same. Please provide valid person IDs to merge."
      next
    end

    puts "The Person ID #{person_to_merge.id} (#{person_to_merge.full_name}) has:\n" \
           "\t#{person_to_merge.role_appointments.count} role appointments #{person_to_merge.role_appointments.map { |ra| ra.role&.name }.to_sentence}\n" \
           "\t#{person_to_merge.historical_account ? '1' : '0'} historical accounts\n" \
           "\t#{person_to_merge.translations.count} translations #{person_to_merge.translations.pluck(:locale).to_sentence}"

    puts "The Person ID #{person_to_keep.id} (#{person_to_keep.full_name}) has:\n" \
           "\t#{person_to_keep.role_appointments.count} role appointments #{person_to_keep.role_appointments.map { |ra| ra.role&.name }.to_sentence}\n" \
           "\t#{person_to_keep.historical_account ? '1' : '0'} historical accounts\n" \
           "\t#{person_to_keep.translations.count} translations #{person_to_keep.translations.pluck(:locale).to_sentence}"

    if person_to_merge.translations.find_by(locale: "en")&.biography != person_to_keep.translations.find_by(locale: "en")&.biography
      puts "The English biographies of the people to merge are different. If the people get merged, you might lose data. Please manually migrate the data and retry."
      next
    end
  end

  desc "Merge people records"
  task :merge_people, %i[person_to_merge person_to_keep] => :environment do |_task, args|
    begin
      person_to_merge = Person.find(args[:person_to_merge])
      person_to_keep = Person.find(args[:person_to_keep])
    rescue ActiveRecord::RecordNotFound
      puts "Please provide valid person IDs to merge."
      next
    end

    person_to_merge_content_id = person_to_merge.content_id

    if person_to_merge == person_to_keep
      puts "The person IDs provided are the same. Please provide valid person IDs to merge."
      next
    end

    if person_to_merge.historical_account
      puts "Please remove the historical account from the person you want to merge, and retry."
      next
    end

    if person_to_merge.translations.count > 1
      puts "Please manually migrate non-English translations from the person you want to merge to the person you want to keep, and retry."
      next
    end

    ActiveRecord::Base.transaction do
      person_to_merge.role_appointments.each do |ra|
        puts "\nLinking role appointment #{ra.id}: '#{ra.role.name}' from person #{person_to_merge.id} (#{person_to_merge.full_name}), to person #{person_to_keep.id} (#{person_to_keep.full_name})"
        ra.update!(person: person_to_keep)
      end

      puts "\nDestroying Person ID: #{person_to_merge.id} (#{person_to_merge.full_name})"
      puts "Person will be permanently deleted, non-retrievable. Please note the following details in Trello tickets for the record"
      puts "==== BEGIN ===="
      puts person_to_merge.attributes
      person_to_merge.reload.destroy!
      puts "==== END ===="
    end

    puts "\nWaiting 10s for changes to propagate through Publishing API, triggering callbacks from Search API, chat, email alerts, etc. before sending a redirect, otherwise the redirect gets overridden...\n"
    10.times do
      sleep(1)
      print "."
    end
    puts "\n"

    puts "\nRedirecting the deleted person of content ID: '#{person_to_merge_content_id}' to the person to keep, at path: '/government/people/#{person_to_keep.slug}'"
    response = PublishingApiRedirectWorker.new.perform(
      person_to_merge_content_id,
      "/government/people/#{person_to_keep.slug}",
      I18n.default_locale.to_s,
    )
    puts response.code
    puts response.raw_response_body
  end

  desc "Reassign role appointment speeches"
  task :reassign_role_appointment_speeches, %i[old_role_appointment_id new_role_appointment_id] => :environment do |_, args|
    begin
      old_role_appointment = RoleAppointment.find(args[:old_role_appointment_id])
    rescue ActiveRecord::RecordNotFound
      shell.say_error "Cannot find old role appointment: #{args[:old_role_appointment_id]}"
      next
    end
    begin
      new_role_appointment = RoleAppointment.find(args[:new_role_appointment_id])
    rescue ActiveRecord::RecordNotFound
      shell.say_error "Cannot find new role appointment: #{args[:new_role_appointment_id]}"
      next
    end
    unless shell.yes?("Proceed with moving speeches from #{old_role_appointment.role_name} to #{new_role_appointment.role_name} (yes/no)")
      shell.say_error "Move aborted"
      next
    end
    new_role_appointment.speeches = old_role_appointment.speeches
    shell.say "Speeches reassigned to #{new_role_appointment.role_name}"
  end
end
