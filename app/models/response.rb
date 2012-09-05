class Response < ActiveRecord::Base
  has_many :consultation_response_attachments, dependent: :destroy
  has_many :attachments, through: :consultation_response_attachments
  accepts_nested_attributes_for :consultation_response_attachments, reject_if: :all_blank
end