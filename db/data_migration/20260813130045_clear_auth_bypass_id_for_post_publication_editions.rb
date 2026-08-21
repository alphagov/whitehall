editions = Edition
             .where(state: Edition::POST_PUBLICATION_STATES - %w[superseded])
             .where.not(auth_bypass_id: nil)

total = editions.count
started_at = Time.current

editions.find_each do |edition|
  edition.auth_bypass_id = nil
  EditionAuthBypassAssetPropagator.new(edition).propagate
end

editions.update_all(auth_bypass_id: nil)

puts "Cleared auth_bypass_id for #{total} editions in #{(Time.current - started_at).round(2)}s"
