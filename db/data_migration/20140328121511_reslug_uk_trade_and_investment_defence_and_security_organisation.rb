OLD_SLUG = 'the-uk-trade-and-investment-defence-and-security-organisation'
NEW_SLUG = 'uk-trade-and-investment-defence-and-security-organisation'

organisation = Organisation.find_by_slug(OLD_SLUG)
organisation.update_attribute(:slug, NEW_SLUG)
organisation.published_editions.each(&:update_in_search_index)
