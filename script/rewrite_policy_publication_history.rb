# Rewrites the history of publications to include that of their original
# publications.
#
# NOTE: This script is NOT idempotent and so should only be run once!
require 'csv'

mapping_csv_path = Rails.root+"lib/tasks/election/2015-04-20-13-42-38-policy_paper_creation_output.csv"
logger = Logger.new(STDOUT)

# Make sure no publications have an open edition as we can't handle those
CSV.parse(File.open(mapping_csv_path).read, headers: true).each do |row|
  publication = Publication.find_by_id(row["policy_paper_id"])
  next unless publication

  document = publication.document
  if document.published_edition != document.latest_edition
    @cannot_proceed = true
    logger.warn "Warning: Publication #{document.published_edition.id} has a #{document.latest_edition.state} edition"
  end
end
raise 'Cannot proceed with open editions on publications' if @cannot_proceed

ActiveRecord::Base.transaction do
  CSV.parse(File.open(mapping_csv_path).read, headers: true).each do |row|
    publication = Publication.find(row["policy_paper_id"])
    policy = Policy.find(row['policy_id'])

    DataHygiene::PolicyPublicationHistoryWriter.new(publication, policy, logger).rewrite_history!
  end
end
