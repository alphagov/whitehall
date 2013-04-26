puts "Updating political parties for historical accounts."
HistoricalAccount.all.each do |historical_account|
  historical_account.political_party_ids = [historical_account.political_party_id]
  historical_account.save!
end
puts "Update complete."
