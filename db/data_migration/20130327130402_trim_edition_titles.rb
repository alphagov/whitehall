editions = Edition.includes(:translations).where('edition_translations.title LIKE " %"')
editions.each do |edition|
  if edition.title
    puts "Updating edition '#{edition.title}'"
    edition.translations.each do |translation|
      translation.update_attributes(title: translation.title.strip)
    end
  end
end

puts "Updated #{editions.length} edition titles"
