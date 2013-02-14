class EditionWorldwideOffice < ActiveRecord::Base
  belongs_to :edition
  belongs_to :worldwide_office

  validates :edition, :worldwide_office, presence: true
end
