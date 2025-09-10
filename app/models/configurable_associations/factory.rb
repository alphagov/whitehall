module ConfigurableAssociations
  class Factory
    def initialize(association_configs, edition)
      @association_configs = association_configs
      @edition = edition
    end

    def build(association_key)
      association = associations[association_key]
      raise "Undefined association: #{association_key}" unless association

      config = @association_configs.find { |config| config["key"] == association_key }
      raise "config not found for association: #{association_key}" unless config

      association.call(config, @edition)
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
