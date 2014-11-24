require 'gds-api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

collection = DocumentCollection.find_by_slug('gambling-duty-forms-and-notices')
collection.slug = 'gambling-duty-notices'
collection.save!

router.add_redirect_route("/government/collections/gambling-duty-forms-and-notices",
                          'exact',
                          "/government/collections/gambling-duty-notices")
router.commit_routes

Whitehall::SearchIndex.for(:government).delete("/government/collections/gambling-duty-forms-and-notices")
