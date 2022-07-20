namespace :change_note do
  desc "List change notes for a content ID"
  task :list, %i[content_id] => :environment do |_, args|
    change_history = Document
      .find_by(content_id: args[:content_id])
      .editions
      .where
      .not(major_change_published_at: nil)
      .pluck(:id, :major_change_published_at, :change_note)

    if change_history.empty?
      puts "No change notes found"
      next
    end

    change_history.each do |change|
      puts change.join("\t")
    end
  end

  desc "Amend a change note for an edition"
  task :amend, %i[edition_id new_change_note email] => :environment do |_, args|
    edition = Edition.find(args[:edition_id])
    old_change_note = edition.change_note

    user = User.find_by(email: args[:email])
    unless user
      puts "User with email #{args[:email]} not found"
      next
    end

    # rubocop:disable Rails/SkipsModelValidations
    edition.update_attribute(:change_note, args[:new_change_note])
    # rubocop:enable Rails/SkipsModelValidations

    EditorialRemark.create!(
      edition: edition,
      body: "Updated change note from #{old_change_note} to #{args[:new_change_note]}",
      author: user,
      created_at: Time.zone.now,
      updated_at: Time.zone.now,
    )

    PublishingApiDocumentRepublishingWorker.perform_async(edition.document.id)

    puts "Updated change note from #{old_change_note} to #{args[:new_change_note]}"
  end
end
