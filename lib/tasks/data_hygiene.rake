require "thor"

def shell
  @shell ||= Thor::Shell::Basic.new
end

namespace :data_hygiene do
  desc "Merge people records"
  task :merge_people, %i[person_to_merge person_to_keep] => :environment do |_task, args|
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

    if person_to_merge.historical_account
      puts "Please remove the historical account from the person you want to merge, and retry."
      next
    end

    if person_to_merge.translations.count > 1
      puts "Please manually migrate non-English translations from the person you want to merge to the person you want to keep, and retry."
      next
    end

    if person_to_merge.translations.find_by(locale: "en")&.biography != person_to_keep.translations.find_by(locale: "en")&.biography
      puts "The English biographies of the people to merge are different. If the people get merged, you might lose data. Please manually migrate the data and retry."
      next
    end

    unless shell.yes?("Proceed with merging person of ID ##{person_to_merge} into person of ID ##{person_to_keep}? (yes/no)")
      puts "Merging aborted"
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
      Kernel.sleep(1)
      print "."
    end
    puts "\n"

    person_to_merge_content_id = person_to_merge.content_id
    puts "\nRedirecting the deleted person of content ID: '#{person_to_merge_content_id}' to the person to keep, at path: '/government/people/#{person_to_keep.slug}'"
    response = PublishingApiRedirectJob.new.perform(
      person_to_merge_content_id,
      "/government/people/#{person_to_keep.slug}",
      I18n.default_locale.to_s,
    )
    puts response.code
    puts response.raw_response_body
  end

  # Use with caution: This task will reassign speeches that are in an unmodifiable state
  # It bypasses validation on the Speech model
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
    shell.say "Found #{old_role_appointment.speeches.count} speech(es) to move."
    old_role_appointment.speeches.find_each do |speech|
      speech.role_appointment_id = new_role_appointment.id
      speech.save!(validate: false)
    end

    shell.say "Speeches reassigned to #{new_role_appointment.role_name}"
  end

  desc "Store slug overrides for live editions where a fresh slug would not match the live."
  task :store_slug_override_for_live_editions, %i[edition_state] => :environment do |_, args|
    edition_state = args[:edition_state]
    return unless edition_state.present? && Edition::PUBLISHED_STATES.include?(edition_state)
    mismatches = []
    errors = []

    editions = Edition.where(state: args[:edition_state])
                      .where("slug_override IS NULL OR slug_override = ''")

    total = editions.count
    puts "Checking #{total} published editions with no slug override..."

    editions.find_each.with_index do |edition, i|
      print "." if (i % 100).zero?

      begin
        # Mirrors the early exit in set_slug_from_title:
        # Non-English primaries and CIPs return nil from string_for_slug
        string_for_slug = edition.send(:string_for_slug)
        next if string_for_slug.nil?

        # Mirrors the babosa normalisation in set_slug
        default_slug = string_for_slug.to_slug.normalize(to_ascii: true, max_length: 150).to_s

        candidate_slug = if default_slug.blank?
                           # Mirrors the fallback to document_id for unsupported locales
                           edition.document_id.to_s
                         else
                           # Mirrors the duplicate-checking loop in set_slug
                           found_slug = nil
                           attempt = 1
                           loop do
                             slug_attempt = attempt == 1 ? default_slug : "#{default_slug}--#{attempt}"

                             conflicting = Edition.where_base_path_prefix_matches(edition)
                                                  .where(slug: slug_attempt)
                                                  .where("document_id != ?", edition.document_id)

                             if conflicting.exists?
                               attempt += 1
                             else
                               found_slug = slug_attempt
                               break
                             end
                           end
                           found_slug
                         end

        # Read the raw slug column, bypassing the slug_override reader
        actual_slug = edition[:slug]

        if candidate_slug != actual_slug
          mismatches << {
            id: edition.id,
            type: edition.type,
            title: edition.title,
            actual_slug: actual_slug,
            candidate_slug: candidate_slug,
            slug_from_title: edition[:slug_from_title],
            slug_override: edition[:slug_override],
          }
        end
      rescue => e
        errors << { id: edition.id, error: e.message }
      end
    end

    puts "\nDone."
    puts "Total checked:    #{total}"
    puts "Total mismatches: #{mismatches.count}"
    puts "Total errors:     #{errors.count}"

    if mismatches.any?
      puts "\n--- Mismatches ---"
      mismatches.each do |m|
        puts "Edition #{m[:id]} (#{m[:type]}, #{m[:state]})"
        puts "  Title:           #{m[:title]}"
        puts "  Current slug:    #{m[:actual_slug]}"
        puts "  Candidate slug:  #{m[:candidate_slug]}"
        puts "--------------------------------------------------------------"
      end
    end

    if errors.any?
      puts "\n--- Errors ---"
      errors.each do |e|
        puts "Edition #{e[:id]}: #{e[:error]}"
      end
    end
  end
end
