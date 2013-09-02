# == Schema Information
#
# Table name: group_memberships
#
#  id         :integer          not null, primary key
#  group_id   :integer
#  person_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :person

  validates :person_id, uniqueness: { scope: :group_id }
end
