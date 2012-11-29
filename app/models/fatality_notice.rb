class FatalityNotice < Announcement
  include Edition::RoleAppointments

  belongs_to :operational_field

  validates :operational_field, presence: true
end
