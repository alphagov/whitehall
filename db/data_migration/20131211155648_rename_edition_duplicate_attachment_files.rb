require 'data_hygiene/duplicate_attachment_finder'
require 'data_hygiene/duplicate_attachment_fixer'

class ValidationSkippingPublisher < EditionForcePublisher
  def failure_reason
    nil
  end

private
  def fire_transition!
    edition.force_publish
    edition.force_published = false
    edition.save(validate: false)
    supersede_previous_editions!
  end
end

logger = Logger.new(Rails.root.join('log/attachment_fix.log'))
gds_user = User.find_by_name!('GDS Inside Government Team')
Edition::AuditTrail.whodunnit = gds_user

DataHygiene::DuplicateAttachmentFinder.new.editions.each do |edition|
  if !edition.is_latest_edition?
    logger.warn("Skipping edition #{edition.id}; newer draft exists: #{edition.latest_edition.id}")
    next
  end

  logger.info("Fixing attachments on edition #{edition.id}")
  new_edition = edition.create_draft(gds_user)

  logger.info("\tAttachments before:\t#{edition.attachments.files.collect(&:filename).to_sentence}")
  DataHygiene::DupFilenameAttachmentFixer.new(new_edition).run!
  logger.info("\tAttachments after:\t#{new_edition.attachments.files.collect(&:filename).to_sentence}")

  new_edition.minor_change = true
  new_edition.editorial_remarks.create!(author: gds_user, body: "Duplicate attachment files renamed")
  publisher = ValidationSkippingPublisher.new(new_edition)
  publisher.perform!
  logger.info("\tEdition published #{new_edition.id}")
end
