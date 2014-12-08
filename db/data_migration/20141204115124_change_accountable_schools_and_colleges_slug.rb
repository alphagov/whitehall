require 'gds_api/router'

router = GdsApi::Router.new(Plek.find('router-api'))

policy_documents_slugs = [
  %w(making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget making-schools-and-colleges-more-accountable-and-funding-them-fairly),
  %w(making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget/supporting-pages/national-pupil-database making-schools-and-colleges-more-accountable-and-funding-them-fairly/supporting-pages/national-pupil-database),
  %w(making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget/supporting-pages/reception-baseline-assessment making-schools-and-colleges-more-accountable-and-funding-them-fairly/supporting-pages/reception-baseline-assessment),
]

policy = Document.where(slug: 'making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget', document_type: 'Policy').first
policy.slug = 'making-schools-and-colleges-more-accountable-and-funding-them-fairly'
policy.save!

policy_documents_slugs.each do |old_slug, new_slug|
  router.add_redirect_route("/government/policies/#{old_slug}",
                            'exact',
                            "/government/policies/#{new_slug}")
  puts "Added redirects from #{old_slug} to #{new_slug}"
end

Whitehall::SearchIndex.for(:government).delete("/government/policies/making-schools-and-colleges-more-accountable-and-giving-them-more-control-over-their-budget")
