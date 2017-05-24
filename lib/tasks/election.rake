namespace :election do
  task remove_mp_letters: :environment do
    puts "Removing MP from MP's letters:"
    Person.where('letters LIKE "%MP%"').each do |person|
      puts "updating #{person.name}"
      new_letters = person.letters.gsub(/(^|\s)MP(\s|$)/, '')
      if person.letters != new_letters
        person.update_attribute(:letters, new_letters)
      end
      puts "changed to #{person.name}"
    end
  end

  task republish_political_content: :environment do
    political_document_ids = Edition
      .where(political: true)
      .pluck(:document_id)
      .uniq

    puts "Republishing #{political_document_ids.count} documents"

    political_document_ids.each do |document_id|
      print "."
      PublishingApiDocumentRepublishingWorker.perform_async_in_queue(
        "bulk_republishing",
        document_id
      )
    end
  end
end
