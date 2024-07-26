desc "Delete and unpublish attachment for a superseded edition, and redirect to parent URL"
task :delete_attachment, %i[attachment_content_id] => :environment do |_, args|
  attachments = Attachment.where(content_id: args[:attachment_content_id], deleted: false)
  if attachments.empty?
    puts "Unable to find any non-deleted attachments with content_id #{args[:attachment_content_id]}"
    next
  end

  attachments.each do |attachment|
    edition = attachment.attachable

    unless edition.is_a?(Edition) && edition&.state == "superseded"
      puts "Edition does not exist or edition is not superseded."
      puts "If edition is not superseded, please get user to delete attachment through UI."
      puts "This rake task is only used in situations where we are unable to remove via UI"
      next
    end

    puts "Deleting attachment: #{attachment.title}..."
    attachment_data = attachment.attachment_data
    attachment.destroy!
    ServiceListeners::AttachmentUpdater.call(attachment_data:)

    puts "Unpublishing attachment: #{attachment.title}..."
    edition.translations.each do |translation|
      PublishingApiRedirectWorker.new.perform(
        attachment.content_id,
        edition.public_path,
        translation.locale.to_s,
      )
    end
  end
end
