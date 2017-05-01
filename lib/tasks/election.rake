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
end
