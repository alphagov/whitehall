module ConfigurableAssociations
  class MinisterialRoleAppointments
    def initialize(association)
      @association = association
    end

    def links
      @association.preload(:person)
      {
        role_appointments: @association.map { |role_appointment| role_appointment.person.content_id },
      }
    end

    def selected_ids
      @association.ids
    end

    def options_query
      RoleAppointment.for_ministerial_roles
        .includes(:person)
        .includes(organisations: :translations)
        .ascending_start_date
    end

    def to_partial_path
      "admin/configurable_associations/ministerial_role_appointments"
    end
  end
end
