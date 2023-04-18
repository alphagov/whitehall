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

  def in_location_offices
    offices.select { |office| office.country == @world_location }
  end

  def remote_offices
    offices.reject { |office| office.country == @world_location }
  end

  def remote_services_office
    return nil if in_location_offices.any?
    return nil if remote_offices.empty?

    remote_offices.first
  end

  def remote_services_country
    remote_services_office.country
  end

  def remote_services_organisation
    remote_services_office.organisation
  end
end
