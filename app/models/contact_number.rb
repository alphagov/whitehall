class ContactNumber < ActiveRecord::Base
  belongs_to :contact
  validates :label, :number, presence: true, length: { maximum: 255 }

  include TranslatableModel
  translates :label, :number
end
