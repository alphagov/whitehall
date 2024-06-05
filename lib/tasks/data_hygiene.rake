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

  desc "Bulk update the organisations associated with documents."
  task :bulk_update_organisation, %i[csv_filename] => :environment do |_, args|
    DataHygiene::BulkOrganisationUpdater.call(args[:csv_filename])
  end

  desc "Merge one role into another"
  task :merge_roles, %i[role_to_be_deleted role_to_be_merged_into] => :environment do |_task, _args|
    role_to_be_deleted = Role.find(role_to_be_deleted) # slug: minister-of-state--48, id: 2377
    role_to_be_merged_into = Role.find(role_to_be_merged_into) # slug: minister-of-state--150, id: 4494

    ActiveRecord::Base.transaction do
      role_to_be_deleted.edition_roles.each do |role|
        role.update!(role: role_to_be_merged_into)
      end
      role_to_be_deleted.organisation_roles.each do |role|
        role.update!(role: role_to_be_merged_into)
      end
      role_to_be_deleted.worldwide_organisation_roles.each do |role|
        role.update!(role: role_to_be_merged_into)
      end
      role_to_be_deleted.role_appointments.each do |appointment|
        appointment.update!(role: role_to_be_merged_into)
      end
      role_to_be_deleted.historical_account_role&.update!(role: role_to_be_merged_into)
      role_to_be_deleted.translations.delete_all
      role_to_be_merged_into.save! # triggers callbacks to Publishing API
      # NB: 'Announcements' may continue to be out of date for at least 5 minutes:
      # https://github.com/alphagov/collections/blob/2586198bdc7e9bce83ac73212b3d1a8314d0f66e/app/lib/services.rb#L10
    end

    # TODO: Unpublish role_to_be_deleted and redirect to role_to_be_merged_into
    # and only then delete `role_to_be_deleted.delete` (if at all?)
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
end
