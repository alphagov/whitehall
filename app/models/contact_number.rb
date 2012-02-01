class ContactNumber < ActiveRecord::Base
  belongs_to :contact
  validates :label, :number, presence: true
end