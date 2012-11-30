class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :person
end
