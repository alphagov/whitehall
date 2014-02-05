router = GdsApi::Router.new(Plek.current.find('router-api'))

# hanover -> hamburg
OLD_HAMBURG_SLUG = 'british-honorary-consul-hanover'
NEW_HAMBURG_SLUG = 'british-honorary-consul-hamburg'

hamburg_consul = WorldwideOffice.find_by_slug(OLD_HAMBURG_SLUG)
hamburg_consul.update_attribute(:slug, NEW_HAMBURG_SLUG)

router.add_redirect_route("/government/world/organisations/british-embassy-berlin/office/#{OLD_HAMBURG_SLUG}",
                          'exact',
                          "/government/world/organisations/british-embassy-berlin/office/#{NEW_HAMBURG_SLUG}")

# armenia -> yerevan
OLD_YEREVAN_SLUG = 'british-embassy-armenia'
NEW_YEREVAN_SLUG = 'british-embassy-yerevan'

yerevan_embassy = WorldwideOrganisation.find_by_slug(OLD_YEREVAN_SLUG)
yerevan_embassy.update_attribute(:slug, NEW_YEREVAN_SLUG)

router.add_redirect_route("/government/world/organisations/#{OLD_YEREVAN_SLUG}",
                          'exact',
                          "/government/world/organisations/#{NEW_YEREVAN_SLUG}")

# tallin -> tallinn
OLD_TALLINN_SLUG = 'british-embassy-tallin'
NEW_TALLINN_SLUG = 'british-embassy-tallinn'

tallinn_embassy = WorldwideOrganisation.find_by_slug(OLD_TALLINN_SLUG)
tallinn_embassy.update_attribute(:slug, NEW_TALLINN_SLUG)

router.add_redirect_route("/government/world/organisations/#{OLD_TALLINN_SLUG}",
                          'exact',
                          "/government/world/organisations/#{NEW_TALLINN_SLUG}")

# organisation -> organization
# coopertation -> cooperation
OLD_OSCE_SLUG = 'organisation-for-security-and-co-opertation-in-europe'
NEW_OSCE_SLUG = 'organization-for-security-and-co-operation-in-europe'

osce = WorldwideOrganisation.find_by_slug(OLD_OSCE_SLUG)
osce.update_attribute(:slug, NEW_OSCE_SLUG)

router.add_redirect_route("/government/world/organisations/#{OLD_OSCE_SLUG}",
                          'exact',
                          "/government/world/organisations/#{NEW_OSCE_SLUG}")
