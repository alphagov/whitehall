namespace :election do
  desc "Republishes all case studies to the Publishing API"
  task :republish_case_studies => :environment do
    require 'data_hygiene/publishing_api_republisher'

    DataHygiene::PublishingApiRepublisher.new(CaseStudy.published).perform
  end

  desc "Creates the associations between all editions and new/future policies, based on their existing policy relations"
  task :migrate_old_policy_taggings_to_new => :environment do
    require 'data_hygiene/future_policy_tagging_migrator'

    edition_scope = Edition.
                      where(type: policy_taggable_edition_classes).
                      where(state: editable_edition_states).
                      includes(related_policies: :related_documents)

    DataHygiene::FuturePolicyTaggingMigrator.new(edition_scope, Logger.new(STDOUT)).migrate!
  end

  desc "Publishes policy papers that were converted from old-world policies."
  task :publish_policy_papers => :environment do
    mapping_csv_path = Rails.root+"lib/tasks/election/2015-04-20-13-42-38-policy_paper_creation_output.csv"
    policy_paper_ids = CSV.parse(File.open(mapping_csv_path).read, headers: true).map do |row|
      row["policy_paper_id"]
    end

    require_relative "election/policy_paper_publisher"
    Election::PolicyPaperPublisher.new(policy_paper_ids).run!
  end

private

  def editable_edition_states
    Edition.state_machine.states.map(&:name) - [:superseded, :deleted, :archived]
  end

  def policy_taggable_edition_classes
    Whitehall.edition_classes.select { |klass| klass.ancestors.include?(Edition::RelatedPolicies) }
  end
end
