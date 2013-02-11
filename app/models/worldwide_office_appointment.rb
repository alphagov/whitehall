class WorldwideOfficeAppointment < ActiveRecord::Base
  belongs_to :person
  belongs_to :worldwide_office

  validates :job_title, presence: true

  def name
    job_title
  end

  def current_person
    person
  end

  def ministerial?
    false
  end
end
