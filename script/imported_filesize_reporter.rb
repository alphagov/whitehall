# Calculates average file size per attachment,
# And average total usage per imported row.

include ActionView::Helpers::NumberHelper

file_sizes = Hash.new {|hash, key| hash[key] = []}

Document.find_each do |document|
  latest_edition = document.latest_edition
  next unless latest_edition
  next unless latest_edition.respond_to? :attachments
  next unless latest_edition.attachments.any?
  total_for_edition = latest_edition.attachments.map { |attachment|
    attachment.file_size
  }.inject(:+)
  (file_sizes[latest_edition.class.name] ||= []) << total_for_edition
end

file_sizes.each do |document_type, sizes|
  puts "#{document_type.underscore.humanize}: #{number_to_human_size(sizes.inject(:+))} (avg: #{number_to_human_size(sizes.inject(:+) / sizes.size)} from #{sizes.size} documents)"
end
