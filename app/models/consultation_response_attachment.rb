class ConsultationResponseAttachment < ActiveRecord::Base
  belongs_to :response
  belongs_to :attachment
  accepts_nested_attributes_for :attachment, reject_if: :all_blank
end