puts "Removing MP from MP's letters:"
Person.where('letters LIKE "%MP%"').each do |person|
  new_letters = person.letters.gsub(/(^|\s)MP(\s|$)/, "")
  if person.letters != new_letters
    puts "\tUpdating '#{person.letters}' to '#{new_letters}' for #{person.slug}"
    person.update!(letters: new_letters)
  end
end
