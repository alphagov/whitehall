class WorldwideOfficeRole < ActiveRecord::Base
  belongs_to :worldwide_office
  belongs_to :role

  validates :worldwide_office, :role, presence: true
end
