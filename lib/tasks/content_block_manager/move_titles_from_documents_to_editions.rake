desc "Moves the title from Content Block Documents to any Editions that do not have titles."
task :move_titles_from_documents_to_editions, %i[confirmation_string] => :environment do |_, args|
  document_count = 0
  edition_count = 0
  confirmation_string = args[:confirmation_string]
  is_real = confirmation_string == "run_for_real"

  ContentBlockManager::ContentBlock::Document.find_each do |document|
    document_count += 1

    document.editions.each do |edition|
      document = edition.document
      if edition.title.blank?
        if is_real
          edition.update!(title: document.title)
        else
          edition.assign_attributes(title: document.title)
        end
        edition_count += 1
        puts "Edition title set to #{edition.title} for Edition #{edition.id}"
      else
        puts "Skipping Edition #{edition.id} because title already set"
      end
    end
  end

  if is_real
    puts "Titles were changed from #{document_count} documents to #{edition_count} editions."
  else
    puts "This was a dry run. Titles would have been changed from #{document_count} documents to #{edition_count} editions."
  end
end
