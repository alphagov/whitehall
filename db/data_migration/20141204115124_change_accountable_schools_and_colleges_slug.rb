require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

policy = Document.where(slug: 'making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget', document_type: 'Policy').first
policy.slug = 'making-schools-and-colleges-more-accountable-and-funding-them-fairly'
policy.save!

router.add_redirect_route("/government/policies/making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget",
                          'exact',
                          "/government/policies/making-schools-and-colleges-more-accountable-and-funding-them-fairly")
router.commit_routes

Whitehall::SearchIndex.for(:government).delete("/government/policies/making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget")
