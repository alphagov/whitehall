class ConsultationResponseAttachment < ActiveRecord::Base
  belongs_to :response
  belongs_to :attachment

  validates :response_id, :attachment_id, presence: true

  accepts_nested_attributes_for :attachment, reject_if: :all_blank
end