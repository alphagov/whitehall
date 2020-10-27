namespace :db do
  desc "Report any data integrity issues"
  task lint: :environment do
    require "data_hygiene/orphaned_attachment_finder"
    o = DataHygiene::OrphanedAttachmentFinder.new
    warn o.summarize_by_type
  end
end

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

  desc "Update all Worldwide Organisations' sponsoring organisation from FCO to FCDO"
  task update_sponsoring_organisation_from_fco_to_fcdo: :environment do
    fco = Organisation.find_by(slug: "foreign-commonwealth-office")
    fcdo = Organisation.find_by(slug: "foreign-commonwealth-development-office")

    Sponsorship.where(organisation: fco).each do |sponsorship|
      sponsorship.update!(organisation: fcdo)
      puts "#{sponsorship.worldwide_organisation.name} updated from FCO to FCDO."
    end
  end

  desc "Ensure there is only one statistics announcement per publication"
  task ensure_statistics_announcement_unique: :environment do
    announcements_by_id = StatisticsAnnouncement.where.not(publication_id: nil).group_by(&:publication_id).filter { |_s, p| p.count > 1 }
    announcements_by_id.each_value do |announcements|
      announcements.sort_by(&:created_at)[1..-1].each do |announcement|
        announcement.publication = nil
      end
    end
  end
end
