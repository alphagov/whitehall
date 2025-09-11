module ConfigurableAssociations
  class MinisterialRoleAppointments
    def initialize(association)
      @association = association
    end

    def selected_ids
      @association.ids
    end

    def scoped_appointments
      RoleAppointment.for_ministerial_roles
        .includes(:person)
        .includes(organisations: :translations)
        .ascending_start_date
    end

    def template_cache_digest
      role_appointment_timestamps = scoped_appointments.pluck(:updated_at)
      update_timestamps = role_appointment_timestamps.map(&:to_i).join
      Digest::MD5.hexdigest "role-appointments-#{update_timestamps}"
    end

    def to_partial_path
      "admin/configurable_associations/ministerial_role_appointments"
    end
  end
end
