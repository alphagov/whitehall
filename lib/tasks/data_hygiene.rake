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

  desc "Make attachments' command paper numbers valid and republish affected documents"
  namespace :make_command_paper_numbers_valid do
    def call_attachment_attribute_updater(dry_run:)
      affected_attachments = []
      Attachment
        .not_deleted
        .where.not(command_paper_number: nil)
        .where.not(command_paper_number: "")
        .where.not(attachable_id: nil)
        .each do |attachment|
        old_attr = attachment.command_paper_number
        begin
          new_attr = DataHygiene::AttachmentAttributeUpdater.call(attachment, dry_run: dry_run)
          if old_attr == new_attr
            puts "Attachment ID #{attachment.id} command paper number is already valid. Skipping..."
          else
            affected_attachments << attachment
            if dry_run
              puts "Attachment ID #{attachment.id} command paper number would have changed from #{old_attr} to #{new_attr}"
            else
              puts "Updated attachment ID #{attachment.id} command paper number from #{old_attr} to #{new_attr}"
            end
          end
        rescue DataHygiene::AttachmentAttributeNotFixable
          puts "Attachment ID #{attachment.id} command paper number cannot be fixed automatically: #{old_attr}"
        end
      end

      puts "Attachments updated: #{affected_attachments.map(&:id).join(', ')}"

      edition_ids = affected_attachments.map do |attachment|
        case attachment.attachable_type
        when "Edition"
          attachment.attachable_id
        when "Response"
          Response.where(id: attachment.attachable_id).pluck(:edition_id).first
        else
          raise "Unknown attachable type #{attachment.attachable_type}"
        end
      end

      document_ids = Document.joins(:editions).where("editions.id": edition_ids).pluck(:document_id).uniq

      puts "Documents affected: #{document_ids.join(', ')}"

      if dry_run
        puts "Dry run. Skipping sending #{document_ids.count} documents to Publishing API"
      else
        puts "Sending #{document_ids.count} documents to Publishing API"
        document_ids.each do |doc_id|
          PublishingApiDocumentRepublishingWorker.new.perform(doc_id, true)
        end
      end
    end

    task dry: :environment do
      call_attachment_attribute_updater(dry_run: true)
    end

    task real: :environment do
      ActiveRecord::Base.transaction do
        call_attachment_attribute_updater(dry_run: false)
      end
    end
  end
end
