puts "Withdrawing HTML attachments for withdrawn editions"

count = 0
Publication.withdrawn.includes(:attachments).find_in_batches do |edition|
  count += 1
  PublishingApiHtmlAttachments.process(edition, "withdraw")
end

puts "Withdrew HTML attachments for #{count} editions"

