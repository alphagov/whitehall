total_count = Edition.count
changed_count = 0
Edition.where(summary: nil).find_each do |edition|
  edition.update_column(:summary, Whitehall::Uploader::Parsers::SummariseBody.parse(edition.body))
  changed_count += 1
end

puts "Total: #{total_count}, changed: #{changed_count}"