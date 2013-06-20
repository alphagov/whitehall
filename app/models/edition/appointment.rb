module Edition::Appointment
  extend ActiveSupport::Concern

  included do
    belongs_to :role_appointment

    delegate :role, to: :role_appointment

    validates :role_appointment, presence: true, unless: ->(edition) { edition.can_have_some_invalid_data? || edition.person_override? }

  end

  def person
    if person_override?
      person_override
    else
      role_appointment.person
    end
  end

  module InstanceMethods
    def search_index
      if person_override?
        super
      else
        super.merge("people" => [person.slug])
      end
    end
  end
end
