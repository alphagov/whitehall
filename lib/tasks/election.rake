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
      PublishingApiDocumentRepublishingJob.perform_async_in_queue(
        "bulk_republishing",
        document_id,
        true, # bulk_publishing
      )
    end
  end

  desc "
    Removes all current ministerial appointments with the exception of the prime minister.
    Usage:
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
    Mark editions of a given organisation as political.
    Used to retrospectively mark content as political when an organisation is changed to be political.
    Usage:
      rake election:mark_political_content_for[organisation_slug,2024-12-03,true]
    "
  task :mark_political_content_for, %i[slug date dry_run] => :environment do |_t, args|
    # The organisation should be marked as political before this is run.
    # The rake task is typically run with the created_at date of the organisation.
    # This only updates documents in Whitehall. To update documents downstream, use the Whitehall UI bulk republish feature,
    # with the 'All documents by organisation' option, or the `republish_political_content` rake task.
    date = Date.parse(args[:date])
    org = Organisation.find_by!(slug: args[:slug])
    dry_run = args[:dry_run]&.to_s&.downcase == "true"
    puts "Adding the political marker to documents tagged to '#{org.name}'..."

    editions = org.editions
    post_publication_editions = editions.where(state: Edition::PUBLICLY_VISIBLE_STATES + %w[unpublished]).where("first_published_at >= ?", date)
    pre_publication_editions_of_published_documents = Edition.in_pre_publication_state.where(document_id: post_publication_editions.map(&:document_id))

    # Run the evaluation logic to determine which editions are now considered political.
    post_publication_potentially_political_editions = post_publication_editions.select { |edition| PoliticalContentIdentifier.political?(edition) }
    pre_publication_potentially_political_editions = pre_publication_editions_of_published_documents.select { |edition| PoliticalContentIdentifier.political?(edition) }
    total_potentially_political_editions = (post_publication_potentially_political_editions + pre_publication_potentially_political_editions).size

    # Get all the editions that are currently marked as political in the DB to capture where manual overrides have been made and to avoid marking them again.
    post_publication_already_political_editions = post_publication_potentially_political_editions.select(&:political?)
    pre_publication_already_political_editions = pre_publication_potentially_political_editions.select(&:political?)
    total_already_political_editions = (post_publication_already_political_editions + pre_publication_already_political_editions).size

    # Only mark the editions that are not already marked as political.
    post_publication_editions_about_to_be_marked_political = post_publication_potentially_political_editions - post_publication_already_political_editions
    pre_publication_editions_about_to_be_marked_political = pre_publication_potentially_political_editions - pre_publication_already_political_editions
    editions_about_to_be_marked_political = post_publication_editions_about_to_be_marked_political + pre_publication_editions_about_to_be_marked_political

    post_publication_states = (Edition::PUBLICLY_VISIBLE_STATES + %w[unpublished]).join(", ")
    pre_publication_states = Edition::PRE_PUBLICATION_STATES.join(", ")

    puts <<~INFO
      Organisation: #{org.name} (created at: #{org.created_at})
      Date threshold, after which the political marker will be set: #{date}
      Total editions in organisation: #{editions.size}
      Total potentially political editions: #{total_potentially_political_editions}, out of which #{total_already_political_editions} are already political.
        Post-publication editions (#{post_publication_states}): #{post_publication_potentially_political_editions.size}, out of which #{post_publication_already_political_editions.size} are already political.
        Pre-publication editions (#{pre_publication_states}): #{pre_publication_potentially_political_editions.size}, out of which #{pre_publication_already_political_editions.size} are already political.

      Editions about to be marked political: #{editions_about_to_be_marked_political.size}
        Post-publication editions (#{post_publication_states}): #{post_publication_editions_about_to_be_marked_political.size}
        Pre-publication editions (#{pre_publication_states}): #{pre_publication_editions_about_to_be_marked_political.size}
    INFO

    unless shell.yes?("You're about to add the 'political' marker to #{editions_about_to_be_marked_political.size} editions associated with '#{org.name}' since #{date}. Dry run is #{dry_run ? 'enabled' : 'disabled'}. Proceed? (yes/no)")
      shell.say_error "Cancelled"
      next
    end

    editions_about_to_be_marked_political.each do |edition|
      edition.update_column(:political, true) unless dry_run
      puts "ID: #{edition.id} (#{edition.type}, #{edition.state}, #{edition.political? ? 'political' : 'not political'}) - #{edition.title} #{dry_run ? 'will be marked as political' : '- DONE'}"
    end

    puts "\nRake task DONE.\nTo update documents downstream, use the Whitehall UI bulk republish feature, with the 'All documents by organisation' option, or the 'election:republish_political_content' rake task."
  rescue Date::Error => _e
    puts "The date is not in the right format [\"#{args[:date]}\"]"
  rescue ActiveRecord::RecordNotFound => _e
    puts "There is no Organisation with slug [\"#{args[:slug]}\"]"
  end

  desc "
    Remove political marker from editions of a given organisation.
    Used to retrospectively unmark political content when an organisation is changed to no longer be political.
    Usage:
      rake election:unmark_political_content_for[organisation_slug,2024-12-03,true]
    "

  task :unmark_political_content_for, %i[slug date dry_run] => :environment do |_t, args|
    # The organisation should have the political marker removed before this is run.
    # The rake task is typically run with the created_at date of the organisation.
    # This only updates documents in Whitehall. To update documents downstream, use the Whitehall UI bulk republish feature,
    # with the 'All documents by organisation' option.
    # Note that the current logic removes the political marker from all editions, regardless of how the marker was added.
    date = Date.parse(args[:date])
    org = Organisation.find_by!(slug: args[:slug])
    dry_run = args[:dry_run]&.to_s&.downcase == "true"
    puts "Removing the political marker for documents tagged to '#{org.name}'..."

    editions = org.editions
    post_publication_editions = editions.where(state: Edition::PUBLICLY_VISIBLE_STATES + %w[unpublished]).where("first_published_at >= ?", date)
    pre_publication_editions_of_published_documents = Edition.in_pre_publication_state.where(document_id: post_publication_editions.map(&:document_id))

    # Get all the editions that are currently marked as political in the DB, for comparison with the editions that will be marked as not political.
    all_post_publication_political_editions = post_publication_editions.select(&:political?)
    all_pre_publication_political_editions = pre_publication_editions_of_published_documents.select(&:political?)
    all_political_editions = all_post_publication_political_editions + all_pre_publication_political_editions

    # Run the evaluation logic to determine which editions are now considered not political.
    # Note that it cannot be deduced which editions were manually marked as political by a publisher, and which by the system, once the organisation has had the political flag removed.
    # The rake task will unset the marker for all editions, based on the PoliticalContentIdentifier's evaluation logic.
    # If you want to persist the manually set political marker, run the evaluator logic for all editions before the organisation is marked as not political.
    # The editions which show the flag as true in the DB but evaluate as false are the ones manually set as political.
    post_publication_editions_evaluated_as_not_political = post_publication_editions.select { |e| PoliticalContentIdentifier.political?(e) == false }
    pre_publication_editions_evaluated_as_not_political = pre_publication_editions_of_published_documents.select { |e| PoliticalContentIdentifier.political?(e) == false }
    all_editions_evaluated_as_not_political = post_publication_editions_evaluated_as_not_political + pre_publication_editions_evaluated_as_not_political

    # Only revert the flag on the editions that actually have the marker true in the DB to avoid unnecessarily updating editions that are already not political.
    post_publication_editions_about_to_be_marked_not_political = post_publication_editions_evaluated_as_not_political.select(&:political?)
    pre_publication_editions_about_to_be_marked_not_political = pre_publication_editions_evaluated_as_not_political.select(&:political?)
    all_editions_about_to_be_marked_not_political = post_publication_editions_about_to_be_marked_not_political + pre_publication_editions_about_to_be_marked_not_political

    # Determine which editions will remain political, likely due to having other editions that are still political.
    post_publication_editions_that_will_remain_political = all_post_publication_political_editions - post_publication_editions_about_to_be_marked_not_political
    pre_publication_editions_that_will_remain_political = all_pre_publication_political_editions - pre_publication_editions_about_to_be_marked_not_political
    all_editions_that_will_remain_political = post_publication_editions_that_will_remain_political + pre_publication_editions_that_will_remain_political

    pre_publication_states = Edition::PRE_PUBLICATION_STATES.join(", ")
    post_publication_states = (Edition::PUBLICLY_VISIBLE_STATES + %w[unpublished]).join(", ")
    puts <<~INFO
      Organisation: #{org.name} (created at: #{org.created_at})
      Date threshold, after which the political marker will be removed: #{date}
      Total editions in organisation: #{editions.size}
      Total political (political marker current true in DB) editions: #{all_political_editions.size}
        Post-publication political editions (#{post_publication_states}): #{all_post_publication_political_editions.size}
        Pre-publication political editions (#{pre_publication_states}): #{all_pre_publication_political_editions.size}
      Total editions that will remain political (likely due to having other editions that are still political): #{all_editions_that_will_remain_political.size}
        Post-publication editions that will remain political (#{post_publication_states}): #{post_publication_editions_that_will_remain_political.size} - #{post_publication_editions_that_will_remain_political.size.positive? ? post_publication_editions_that_will_remain_political.map(&:id) : '[]'}
        Pre-publication editions that will remain political (#{pre_publication_states}): #{pre_publication_editions_that_will_remain_political.size} - #{pre_publication_editions_that_will_remain_political.size.positive? ? pre_publication_editions_that_will_remain_political.map(&:id) : '[]'}
      Editions about to be marked 'not political' (political marker currently true in DB): #{all_editions_about_to_be_marked_not_political.size} out of #{all_editions_evaluated_as_not_political.size} editions evaluated as not political
        Post-publication editions (#{post_publication_states}): #{post_publication_editions_about_to_be_marked_not_political.size} out of #{post_publication_editions_evaluated_as_not_political.size} editions evaluated as not political
        Pre-publication editions (#{pre_publication_states}): #{pre_publication_editions_about_to_be_marked_not_political.size} out of #{pre_publication_editions_evaluated_as_not_political.size} editions evaluated as not political
    INFO

    unless shell.yes?("You're about to remove the political marker for #{all_editions_about_to_be_marked_not_political.size} editions associated with '#{org.name}' since #{date}. Dry run is #{dry_run ? 'enabled' : 'disabled'}. Proceed? (yes/no)")
      shell.say_error "Cancelled"
      next
    end

    all_editions_about_to_be_marked_not_political.each do |edition|
      edition.update_column(:political, false) unless dry_run
      puts "ID: #{edition.id} (#{edition.type}, #{edition.state}, #{edition.political? ? 'political' : 'not political'}) - #{edition.title} #{dry_run ? 'will be marked as not political' : '- DONE'}"
    end

    puts "\nRake task DONE.\nTo update documents downstream, use the Whitehall UI bulk republish feature, with the 'All documents by organisation' option."
  rescue Date::Error => _e
    puts "The date is not in the right format [\"#{args[:date]}\"]"
  rescue ActiveRecord::RecordNotFound => _e
    puts "There is no Organisation with slug [\"#{args[:slug]}\"]"
  end
end
