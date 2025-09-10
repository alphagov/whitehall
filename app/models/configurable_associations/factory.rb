module ConfigurableAssociations
  class Factory
    def initialize(edition)
      @edition = edition
    end

    def configurable_associations
      @edition.type_instance.associations.map do |association_config|
        association = associations[association_config["key"]]
        raise "Undefined association: #{association_config['key']}" unless association

        association.call(association_config, @edition)
      end
    end

  private

    def associations
      {
        "role_appointments" => ->(config, edition) { ConfigurableAssociations::RoleAppointments.new(config, edition.role_appointments) },
        "topical_events" => ->(config, edition) { ConfigurableAssociations::TopicalEvents.new(config, edition.topical_events) },
      }.freeze
    end
  end
end
