# == Schema Information
#
# Table name: edition_policy_groups
#
#  id              :integer          not null, primary key
#  edition_id      :integer
#  policy_group_id :integer
#

class EditionPolicyGroup < ActiveRecord::Base
  belongs_to :edition
  belongs_to :policy_group

  belongs_to :policy, class_name: 'Policy', foreign_key: :edition_id
end
