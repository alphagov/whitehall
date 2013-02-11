# Calculates average file size per attachment,
# And average total usage per imported row.

include ActionView::Helpers::NumberHelper

query = ActiveRecord::Base.connection.execute(%Q{
SELECT e.type, COUNT(e.id), SUM(ad.file_size) FROM attachment_data ad
  JOIN (SELECT attachment_data_id, id FROM attachments GROUP BY attachment_data_id) a ON a.attachment_data_id = ad.id
  LEFT JOIN edition_attachments ea ON ea.attachment_id = a.id
  JOIN (SELECT id, type FROM editions WHERE editions.type IS NOT NULL) e ON e.id = ea.edition_id
GROUP BY e.type;
})
query.each do |row|
  next if row.first.nil?
  document_type, count, file_size = row
  puts "#{document_type.underscore.humanize} -> #{number_to_human_size(file_size.to_f)} (average #{number_to_human_size(file_size.to_f / count.to_f)} from #{count.to_i} documents)"
end
