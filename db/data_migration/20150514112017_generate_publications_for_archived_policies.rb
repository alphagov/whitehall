require 'gds_api/router'

POLICY_TO_PUBLICATION_MAPPINGS = {
  389393 => 489732, # Scottish Referendum
  333505 => 489731, # Reducing corruption in international trade
}.freeze

gds_user = User.find_by!(name: "GDS Inside Government Team")
router = GdsApi::Router.new(Plek.find('router-api'))


POLICY_TO_PUBLICATION_MAPPINGS.each_pair do |policy_id, publication_id|
  policy = Policy.find(policy_id)
  publication = Publication.find(publication_id)

  # Inherits the unpublishing details of the policy
  unpublishing_params = {
    explanation: policy.unpublishing.explanation,
    unpublishing_reason_id: policy.unpublishing.unpublishing_reason_id,
  }

  puts "Archiving publication \"#{publication.title}\""
  archiver = EditionWithdrawer.new(
    publication,
    user: gds_user,
    remark: "Archived",
    unpublishing: unpublishing_params
  )

  if archiver.perform!
    puts "\tArchived with explanation: \"#{publication.unpublishing.explanation}\""
    # fix the data so it shows the appropriate date on the archive notice
    publication.update_column(:updated_at, policy.updated_at)
  else
    puts "\tError: Could not archive publication! #{archiver.failure_reason}"
  end

  # register the appropriate redirects
  policy_path = Whitehall.url_maker.document_path(policy)
  publication_path = Whitehall.url_maker.document_path(publication)
  puts "\tRegistering redirect #{policy_path} => #{publication_path}"
  router.add_redirect_route(policy_path, :exact, publication_path)
end

# commit the registered routes
router.commit_routes
