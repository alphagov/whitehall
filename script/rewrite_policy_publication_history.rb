# Rewrites the history of publications to include that of their original
# publications.
#
# NOTE: This script is NOT idempotent and so should only be run once!
require 'csv'

logger = Logger.new(STDOUT)

def with_publications_and_policies(&block)
  mapping_csv_path = Rails.root.join("lib/tasks/election/2015-04-20-13-42-38-policy_paper_creation_output.csv")

  CSV.parse(File.open(mapping_csv_path).read, headers: true).each do |row|
    publication = Publication.find(row["policy_paper_id"])
    policy = Policy.find(row['policy_id'])
    yield publication, policy
  end
end

logger.info '# Checking for publications with open editions on them...'
with_publications_and_policies do |publication, _|
  document = publication.document
  if document.published_edition != document.latest_edition
    @cannot_proceed = true
    logger.warn "Publication #{document.published_edition.id} has a #{document.latest_edition.state} edition"
  end
end
abort('Cannot proceed with open editions on publications') if @cannot_proceed

logger.info '# Checking for publications with suspect first_published_at dates...'
with_publications_and_policies do |publication, policy|
  latest_edition = publication.document.latest_edition
  if latest_edition.first_published_at.to_date > policy.first_published_at.to_date
    logger.warn "Publication #{publication.id} to be repaired: Frst published is #{latest_edition.first_published_at}; policy has #{policy.first_published_at}"
  end
end

logger.info '# Back-filling publication histories...'
ActiveRecord::Base.transaction do
  with_publications_and_policies do |publication, policy|
    DataHygiene::PolicyPublicationHistoryWriter.new(publication, policy, logger).rewrite_history!
  end
end

logger.info '# Queueing jobs to re-index publications in search'
with_publications_and_policies do |publication, policy|
  publication.document.published_edition.update_in_search_index
end
