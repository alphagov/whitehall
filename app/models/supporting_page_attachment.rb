class SupportingPageAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :supporting_page
end
