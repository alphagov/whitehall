puts "Removing anchor links from broken link reports."

LinksReport.find_each do |report|
  if (anchor_links = report.broken_links.select { |link| link =~ /^#/ })
    print '.'
    report.broken_links -= anchor_links
    report.save!
  end
end

puts "Done."
