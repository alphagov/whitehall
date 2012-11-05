class EditionAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :edition
end
