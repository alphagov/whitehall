class CorporateInformationPageAttachment < ActiveRecord::Base
  belongs_to :corporate_information_page
  belongs_to :attachment, dependent: :destroy

  accepts_nested_attributes_for :attachment, reject_if: :all_blank
end
