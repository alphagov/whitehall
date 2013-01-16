class EditionPolicyGroup < ActiveRecord::Base
  belongs_to :edition
  belongs_to :policy_group

  belongs_to :policy, class_name: 'Policy', foreign_key: :edition_id
end
