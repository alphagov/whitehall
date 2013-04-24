puts "Adding historical account support to the Prime Minister and Chancellor roles"
Role.find_by_slug('prime-minister').update_attribute(:supports_historical_accounts, true)
Role.find_by_slug('chancellor-of-the-exchequer').update_attribute(:supports_historical_accounts, true)
