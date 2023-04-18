class Embassy
  def initialize(world_location)
    @world_location = world_location
  end

  delegate :name, to: :@world_location

  def offices
    consular_services_organisations.map { |org| org.embassy_offices }.flatten
  end

  def consular_services_organisations
    @world_location.worldwide_organisations.select do |org|
      org.embassy_offices.any?
    end
  end

  def remote_services_country
    countries = offices.map(&:country)
    unless countries.empty? || countries.include?(@world_location)
      countries.first
    end
  end

  def remote_services_organisation
    return nil unless remote_services_country

    consular_services_organisations.select { |org| org.world_locations.include?(remote_services_country) }.first
  end
end
