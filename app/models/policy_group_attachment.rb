# == Schema Information
#
# Table name: policy_group_attachments
#
#  id              :integer          not null, primary key
#  policy_group_id :integer
#  attachment_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class PolicyGroupAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :policy_group
end
