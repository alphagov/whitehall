namespace :db do
  desc "Report any data integrity issues"
  task lint: :environment do
    require "data_hygiene/orphaned_attachment_finder"
    o = DataHygiene::OrphanedAttachmentFinder.new
    warn o.summarize_by_type
  end
end

namespace :data_hygiene do
  desc "Remove a change note from a document and represent to the content store."
  namespace :remove_change_note do
    def call_change_note_remover(content_id, locale, query, dry_run:)
      edition = DataHygiene::ChangeNoteRemover.call(
        content_id, locale, query, dry_run: dry_run
      )

      if dry_run
        puts "Would have removed: #{edition.change_note.inspect}"
      else
        puts "Updated change history: #{edition.document.change_history.inspect}"
      end
    rescue DataHygiene::ChangeNoteNotFound
      puts "Could not find a change note."
    end

    task :dry, %i[content_id locale query] => :environment do |_, args|
      call_change_note_remover(args[:content_id], args[:locale], args[:query], dry_run: true)
    end

    task :real, %i[content_id locale query] => :environment do |_, args|
      call_change_note_remover(args[:content_id], args[:locale], args[:query], dry_run: false)
    end
  end

  desc "Bulk update the organisations associated with documents."
  task :bulk_update_organisation, %i(csv_filename) => :environment do |_, args|
    DataHygiene::BulkOrganisationUpdater.call(args[:csv_filename])
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
      speech.save(validate: false)
    end
  end
end
