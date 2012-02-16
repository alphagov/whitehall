class OrganisationPolicyTopic < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :policy_topic
end