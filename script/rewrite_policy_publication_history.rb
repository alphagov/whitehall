# Rewrites the history of publications to include that of their original
# publications.
#
# NOTE: This script is NOT idempotent and so should only be run once!
require 'csv'

mapping_csv_path = Rails.root+"lib/tasks/election/2015-04-20-13-42-38-policy_paper_creation_output.csv"
logger = Logger.new(STDOUT)

ActiveRecord::Base.transaction do
  CSV.parse(File.open(mapping_csv_path).read, headers: true).each do |row|
    publication = Publication.find(row["policy_paper_id"])
    policy = Policy.find(row['policy_id'])

    DataHygiene::PolicyPublicationHistoryWriter.new(publication, policy, logger).rewrite_history!
  end
end
