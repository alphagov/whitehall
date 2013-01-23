total_count = Edition.count
changed_entities_count = 0
changed_attachments_count = 0
Edition.where("summary rlike '&[^ ]+;'").find_each do |edition|
  edition.update_column(:summary, Whitehall::Uploader::Parsers::SummariseBody.parse(edition.body))
  changed_entities_count += 1
end
Edition.where("(summary like '%!@%') or (summary like '%[Inl%')").find_each do |edition|
  edition.update_column(:summary, Whitehall::Uploader::Parsers::SummariseBody.parse(edition.body))
  changed_attachments_count += 1
end

puts "Total: #{total_count}, changed (entities): #{changed_entities_count}, changed (attachments): #{changed_attachments_count}"