module ConfigurableAssociations
  class RoleAppointments
    def initialize(config, association)
      @config = config
      @association = association
    end

    def label
      @config["label"]
    end

    def selected_ids
      @association.ids
    end

    def to_partial_path
      "admin/configurable_associations/role_appointments"
    end
  end
end
