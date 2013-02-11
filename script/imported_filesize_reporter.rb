# Calculates average file size per attachment,
# And average total usage per imported row.

include ActionView::Helpers::NumberHelper

query = ActiveRecord::Base.connection.execute(%Q{
SELECT e.type, SUM(ad.file_size) FROM attachment_data ad
       LEFT JOIN attachments a ON a.attachment_data_id = ad.id
       LEFT JOIN edition_attachments ea ON ea.attachment_id = a.id
       LEFT JOIN editions e ON e.id = ea.edition_id
GROUP BY e.type;
                                              })
query.each do |row|
  next if row.first.nil?
  puts "#{row.first} -> #{number_to_human_size(row[1].to_f)}"
end
