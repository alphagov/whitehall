class PolicyGroupDependency < ApplicationRecord
  belongs_to :policy_group
  belongs_to :dependable, polymorphic: true
end
