require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

person = Person.find_by(slug: 'phillip-marsden')
person.slug = 'philip-marsden'
person.save!

router.add_redirect_route("/government/people/phillip-marsden",
                          'exact',
                          "/government/people/philip-marsden")
router.commit_routes
