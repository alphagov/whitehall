class Response < ActiveRecord::Base
  has_many :consultation_response_attachments, dependent: :destroy
  accepts_nested_attributes_for :consultation_response_attachments, reject_if: :all_blank
end