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
    DataHygiene::BulkOrganisationUpdater.call(File.read(args[:csv_filename]))
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
