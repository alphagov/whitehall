## Historical accounts should only be able to be created for prime minsters and should be have
## one rather than many. This does two things:
## 1. Destroys any historical accounts that exist for foreign secretaries
## 2. Ensures that the only role which supports historical accounts is the prime minister.
HistoricalAccount
.joins(:roles)
.where
.not(roles: { slug: "prime-minister" })
.each(&:destroy!)

Role.where(supports_historical_accounts: true).each do |role|
  role.update!(supports_historical_accounts: false) unless role.slug == "prime-minister"
end
