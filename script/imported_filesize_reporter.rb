# Calculates average file size per attachment,
# And average total usage per imported row.

include ActionView::Helpers::NumberHelper

total_attachment_size = AttachmentData.sum(:file_size)
per_attachment = total_attachment_size / AttachmentData.count

puts "Total uploaded attachments: #{number_to_human_size(total_attachment_size)}"
puts "Size per attachment: #{number_to_human_size(per_attachment)}"
