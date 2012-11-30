class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :person

  validates :person_id, uniqueness: { scope: :group_id }
end
