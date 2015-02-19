require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

world_org = WorldwideOrganisation.find_by(slug: 'uk-trade-investment')
world_org.slug = 'uk-trade-investment-belgium'
world_org.save!

# Redirect old URL to UKTI organisation page.
router.add_redirect_route("/government/world/organisations/uk-trade-investment",
                          'exact',
                          "/government/world/organisations/uk-trade-investment-belgium")
