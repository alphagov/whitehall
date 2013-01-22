total_count = Edition.count
changed_count = 0
Edition.find_each do |edition|
  if edition.summary.blank?
    edition.update_column(:summary, Whitehall::Uploader::Parsers::SummariseBody.parse(edition.body))
    changed_count += 1
  end
end

puts "Total: #{total_count}, changed: #{changed_count}"