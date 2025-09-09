module ConfigurableAssociations
  class RoleAppointments
    delegate :role_appointment_ids, to: :@edition
    def initialize(config, edition)
      @config = config
      @edition = edition
    end

    def label
      @config["label"]
    end

    def to_partial_path
      "admin/configurable_associations/role_appointments"
    end
  end
end
