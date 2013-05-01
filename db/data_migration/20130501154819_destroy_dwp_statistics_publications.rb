# Tracker: https://www.pivotaltracker.com/story/show/49054081
# As DWP
# I want these statistical publications destroyed
# So that I can import up-to-date scraped content, rather than edit old junk from January.

# Criteria: Destroy all
#  - publications
#  - belonging to department-for-work-pensions
#  - in draft, imported or submitted state
#  - with STATS or STATISTICS in upper case at precisely the beginning of the title
dwp = Organisation.find_by_slug('department-for-work-pensions')
puts "Cleaning up junk publications for DWP"
matching_publications = Publication.in_organisation(dwp).where(state: %w(draft imported submitted)).select {|p| p.title =~ /^STAT/ }

puts "About to destroy #{matching_publications.size} publications"
matching_publications.each do |publication|
  puts publication.title
  publication.destroy
end
