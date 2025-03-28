namespace :data_hygiene do
  namespace :remove_change_note do
    desc "Remove a change note from a document and represent to the content store (dry run)."
    task :dry, %i[content_id locale query] => :environment do |_, args|
      edition = DataHygiene::ChangeNoteRemover.call(args[:content_id], args[:locale], args[:query], dry_run: true)
      puts "Would have removed: #{edition.change_note.inspect}"
    end

    desc "Remove a change note from a document and represent to the content store (for reals)."
    task :real, %i[content_id locale query] => :environment do |_, args|
      edition = DataHygiene::ChangeNoteRemover.call(args[:content_id], args[:locale], args[:query], dry_run: false)
      puts "Updated change history: #{edition.document.change_history.inspect}"
    end
  end

  desc "Move content from one role to another (DANGER!)."
  task :migrate_role_content, %i[old_role_appointment new_role_appointment] => :environment do |_task, args|
    old_role_app = RoleAppointment.find(args[:old_role_appointment])
    new_role_app = RoleAppointment.find(args[:new_role_appointment])

    old_role_app.edition_role_appointments.each do |era|
      era.update(role_appointment: new_role_app)
    end

    old_role_app.speeches.each do |speech|
      speech.role_appointment = new_role_app
      speech.save!(validate: false)
    end
  end

  desc "Restore a deleted document by creating a new edition from its latest deleted draft"
  task :restore_deleted_document, %i[document_id user_email] => :environment do |_, args|
    deleted_document_restorer = DataHygiene::DeletedDocumentRestorer.new(args[:document_id], args[:user_email])

    begin
      deleted_document_restorer.run!
      puts "Created a new draft for document with ID #{args[:document_id]}"
    rescue DataHygiene::DeletedDocumentRestorer::RestoreDocumentError => e
      puts e.message
    end
  end

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
        puts "Linking role appointment #{ra.id}: '#{ra.role.name}' from person #{person_to_merge.id} (#{person_to_merge.full_name}), to person #{person_to_keep.id} (#{person_to_keep.full_name})"
        ra.update!(person: person_to_keep)
      end

      person_to_merge_content_id = person_to_merge.content_id

      puts "Destroying Person ID: #{person_to_merge.id} (#{person_to_merge.full_name})"
      person_to_merge.reload.destroy!

      puts "Redirecting the deleted person of content ID: '#{person_to_merge_content_id}' to the person to keep, at path: '/government/people/#{person_to_keep.slug}'"
      Whitehall::PublishingApi.publish_redirect_async(person_to_merge_content_id, "/government/people/#{person_to_keep.slug}")
    end
  end
end
