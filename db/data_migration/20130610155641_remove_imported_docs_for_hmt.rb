imported = Organisation.find(15).editions.imported
old_urls = imported.map do |e|
  e.document.document_sources.map &:url
end
puts "Old URLs"
puts old_urls.flatten
puts "Destroying #{imported.count} imported documents"
imported.each do |e|
  e.document.destroy
end