PolicyTeam.where(name: ["Example policy team", "PLEASE DELETE"]).each do |policy_team|
  puts "Destroying policy team: '#{policy_team.name}'..."
  policy_team.destroy
  puts "[Done]"
end

DocumentSeries.where(slug: ["please-delete-local-authority-capital-expenditure-and-receipts"]).each do |document_series|
  puts "Destroying document series: '#{document_series.slug}'..."
  document_series.destroy
  puts "[Done]"
end

puts "Removing ministerial role: 'DELETE PLEASE' from search index..."
p Rummageable.delete("/government/ministers/parliamentary-under-secretary-of-state-employment-relations-consumer-and-postal-affairs", Whitehall.government_search_index_path)
puts "[Done]"
