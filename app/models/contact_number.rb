# == Schema Information
#
# Table name: contact_numbers
#
#  id         :integer          not null, primary key
#  contact_id :integer
#  label      :string(255)
#  number     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class ContactNumber < ActiveRecord::Base
  belongs_to :contact
  validates :label, :number, presence: true
end
