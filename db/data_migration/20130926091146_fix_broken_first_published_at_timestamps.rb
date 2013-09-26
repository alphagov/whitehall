nineteen_hundreds = Date.new(1900)

documents = Edition.where('first_published_at < ? and state != ?', nineteen_hundreds, 'imported').collect(&:document).uniq
documents.each do |document|
  fallback_timestamp = document.latest_edition.first_published_at

  document.editions.where('first_published_at < ?', nineteen_hundreds).each do |edition|
    if edition.first_published_at < nineteen_hundreds
      if edition.public_timestamp < nineteen_hundreds
        fix = fallback_timestamp
      else
        fix = edition.public_timestamp
      end

      puts "Fixing timestamp on #{edition.id}|#{edition.title} - setting it to #{fix}"
      edition.update_attribute(:first_published_at, fix)
    end
  end
end
