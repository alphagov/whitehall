class ConsultationResponseAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :response
end
