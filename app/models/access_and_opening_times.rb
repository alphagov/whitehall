class AccessAndOpeningTimes < ActiveRecord::Base
  belongs_to :accessible, polymorphic: true

  validates_with SafeHtmlValidator
  validates :body, presence: true
end
