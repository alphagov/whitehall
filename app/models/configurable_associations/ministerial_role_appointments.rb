module ConfigurableAssociations
  class MinisterialRoleAppointments
    def initialize(association)
      @association = association
    end

    def self.edition_concern
      Edition::Organisations
    end

    def links
      @association.includes(:person, :role)

      @association.each_with_object({ people: [], roles: [] }) do |role_appointment, links|
        links[:people] << role_appointment.person.content_id
        links[:roles] << role_appointment.role.content_id
      end
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
