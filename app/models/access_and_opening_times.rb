class AccessAndOpeningTimes < ActiveRecord::Base
  belongs_to :accessible, polymorphic: true

  validates_with SafeHtmlValidator
  validates_with NoFootnotesInGovspeakValidator, attribute: :body

  validates :body, presence: true
end
