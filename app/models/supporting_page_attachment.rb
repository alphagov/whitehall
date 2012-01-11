class SupportingPageAttachment < ActiveRecord::Base
  belongs_to :supporting_page
  belongs_to :attachment, dependent: :destroy
end