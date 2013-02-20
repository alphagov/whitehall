class WorldwideOffice < ActiveRecord::Base
  has_one :contact, as: :contactable, dependent: :destroy
  belongs_to :worldwide_organisation

  validates :worldwide_organisation, :contact, presence: true

  accepts_nested_attributes_for :contact
end
