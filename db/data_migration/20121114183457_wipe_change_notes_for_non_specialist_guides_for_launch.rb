editions_to_update = Edition.where("type <> 'DetailedGuide'")
puts "Updating #{editions_to_update.count} editions"
editions_to_update.update_all("change_note = '', minor_change = true")
