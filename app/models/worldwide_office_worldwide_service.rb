class WorldwideOfficeWorldwideService < ActiveRecord::Base

  belongs_to :worldwide_office
  belongs_to :worldwide_service

  validates :worldwide_service, :worldwide_office, presence: true

end
