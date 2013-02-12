class WorldwideOfficeAppointment < ActiveRecord::Base
  belongs_to :person
  belongs_to :worldwide_office

  validates :job_title, :person, :worldwide_office, presence: true
end
