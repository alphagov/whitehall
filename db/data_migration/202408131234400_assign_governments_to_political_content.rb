political_editions = Edition.where(political: true).where("state != ?", "superseded")

puts "Assigning a government to #{political_editions.count} political editions"

political_editions.find_each do |edition|
  edition.update_column(:government_id, edition.default_government&.id)
end

puts "done"
