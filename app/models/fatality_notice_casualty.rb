class FatalityNoticeCasualty < ActiveRecord::Base
  belongs_to :fatality_notice
  validates :personal_details, presence: true
end
