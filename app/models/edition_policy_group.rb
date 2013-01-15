class EditionPolicyGroup < ActiveRecord::Base
  belongs_to :edition
  belongs_to :policy_group

  belongs_to :policy, foreign_key: :edition_id
end
