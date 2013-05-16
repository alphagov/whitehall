module Edition::RoleAppointments
  extend ActiveSupport::Concern

  class Trait < Edition::Traits::Trait
    def process_associations_before_save(edition)
      edition.role_appointments = @edition.role_appointments
    end
  end

  included do
    has_many :edition_role_appointments, foreign_key: :edition_id, dependent: :destroy
    has_many :role_appointments, through: :edition_role_appointments

    add_trait Trait
  end

  def can_be_associated_with_role_appointments?
    true
  end

  def search_index
    super.merge("people" => role_appointments.map(&:slug))
  end
end
