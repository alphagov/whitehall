class FatalityNotice < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  belongs_to :operational_field

  validates :operational_field, presence: true
end
