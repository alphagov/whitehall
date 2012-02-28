organisations = Organisation.where(acronym: %w(BIS DCLG CO FCO DFID MOJ))
organisations.each do |organisation|
  organisation.contacts.where(description: "DELETE DUPLICATE CONTACT").each do |contact|
    puts "Deleting contact ID: #{contact.id} for organisation: #{organisation.acronym}"
    contact.destroy
  end
end

