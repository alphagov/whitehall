# == Schema Information
#
# Table name: consultation_response_attachments
#
#  id            :integer          not null, primary key
#  response_id   :integer
#  attachment_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class ConsultationResponseAttachment < ActiveRecord::Base
  include ::Attachable::JoinModel
  attachable_join_model_for :response
end
