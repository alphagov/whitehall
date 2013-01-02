module Edition::Appointment
  extend ActiveSupport::Concern

  included do
    belongs_to :role_appointment

    delegate :role, to: :role_appointment

    validates :role_appointment, presence: true, unless: ->(edition) { edition.can_have_some_invalid_data? }

  end

  def person
    role_appointment.person
  end
end
