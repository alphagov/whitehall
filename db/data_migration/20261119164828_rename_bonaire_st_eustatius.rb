OLD_SLUG = "bonaire-st-eustatius-saba".freeze
NEW_SLUG = "bonaire-sint-eustatius-saba".freeze
NEW_NAME = "Bonaire, Sint Eustatius and Saba".freeze

country = WorldLocation.find_by(slug: OLD_SLUG)
if country
  country.update!(slug: NEW_SLUG)
  country.translation.update!(name: NEW_NAME)
end
