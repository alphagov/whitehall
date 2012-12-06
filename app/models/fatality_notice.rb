class FatalityNotice < Announcement
  include Edition::RoleAppointments
  include Edition::FactCheckable
  include Edition::FirstImagePulledOut

  belongs_to :operational_field

  has_many :fatality_notice_casualties, dependent: :destroy

  accepts_nested_attributes_for :fatality_notice_casualties, allow_destroy: true, reject_if: :all_blank

  validates :operational_field, presence: true

  def has_operational_field?
    true
  end

end
