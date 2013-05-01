Organisation.find_each do |organisation|
  if organisation.contacts.any?
    if organisation.home_page_contacts.empty?
      print "CONVERT #{organisation.name}: adding #{organisation.contacts.count} contacts to the home page:"
      organisation.contacts.order(:id).each do |contact|
        organisation.add_contact_to_home_page!(contact)
        print '.'
      end
      puts " DONE!"
    else
      puts "SKIP #{organisation.name}: it has a list of contacts for their home page already"
    end
  else
    puts "SKIP #{organisation.name}: it has no contacts"
  end
end
