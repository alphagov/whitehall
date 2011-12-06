class OrganisationPolicyArea < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :policy_area
end