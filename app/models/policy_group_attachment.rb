class PolicyGroupAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :policy_group
end
