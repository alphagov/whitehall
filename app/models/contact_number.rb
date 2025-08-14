class ContactNumber < ApplicationRecord
  include TranslatableModel

  belongs_to :contact
  validates :label, :number, presence: true, length: { maximum: 255 }
  translates :label, :number
end
