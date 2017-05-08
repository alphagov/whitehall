class WorldwideOfficeWorldwideService < ApplicationRecord

  belongs_to :worldwide_office, inverse_of: :worldwide_office_worldwide_services
  belongs_to :worldwide_service, inverse_of: :worldwide_office_worldwide_services

  validates :worldwide_service, :worldwide_office, presence: true
end
