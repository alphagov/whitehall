OLD_SLUG = "st-maarten".freeze
NEW_SLUG = "sint-maarten".freeze
NEW_NAME = "Sint Maarten".freeze

country = WorldLocation.find_by(slug: OLD_SLUG)
if country
  country.update!(slug: NEW_SLUG)
  country.translation.update!(name: NEW_NAME)
end
