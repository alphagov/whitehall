WorldwideOrganisation.find_each do |worldwide_organisation|
  if worldwide_organisation.offices.any?
    if worldwide_organisation.home_page_offices.empty?
      print "CONVERT #{worldwide_organisation.name}: adding #{worldwide_organisation.offices.count} offices to the home page:"
      worldwide_organisation.offices.order(:id).each do |office|
        worldwide_organisation.add_office_to_home_page!(office)
        print '.'
      end
      puts " DONE!"
    else
      puts "SKIP #{worldwide_organisation.name}: it has a list of offices for their home page already"
    end
  else
    puts "SKIP #{worldwide_organisation.name}: it has no offices"
  end
end
