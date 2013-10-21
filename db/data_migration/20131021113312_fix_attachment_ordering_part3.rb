require 'cleanups/attachment_ordering_fixer'
require 'logger'
logger = Logger.new(STDOUT)
AttachmentOrderingFixer.run!(logger: logger)
