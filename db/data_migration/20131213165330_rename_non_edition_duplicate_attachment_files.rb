require 'data_hygiene/duplicate_attachment_finder'
require 'data_hygiene/duplicate_attachment_fixer'

logger = Logger.new(Rails.root.join('log/attachment_fix.log'))

DataHygiene::DuplicateAttachmentFinder.new.non_editions.each do |model|
  logger.info("Cleaning up #{model.class.name} : #{model.id}")
  logger.info("\tAttachments before:\t#{model.attachments.collect(&:filename).to_sentence}")
  DataHygiene::DupFilenameAttachmentFixer.new(model).run!
  logger.info("\tAttachments after:\t#{model.reload.attachments.collect(&:filename).to_sentence}")
end
