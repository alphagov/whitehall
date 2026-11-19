OLD_SLUG = "bahamas".freeze
NEW_SLUG = "the-bahamas".freeze
NEW_NAME = "The Bahamas".freeze

country = WorldLocation.find_by(slug: OLD_SLUG)
if country
  country.update!(slug: NEW_SLUG)
  country.translation.update!(name: NEW_NAME)
end
