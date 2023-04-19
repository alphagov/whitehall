class Embassy
  def initialize(world_location)
    @world_location = world_location
  end

  delegate :name, to: :@world_location

  def offices
    @world_location.worldwide_organisations.map(&:embassy_offices).flatten
  end

  def consular_services_organisations
    @world_location.worldwide_organisations.select do |org|
      org.embassy_offices.any?
    end
  end

  def remote_services_country
    offices = consular_services_organisations.map(&:offices).flatten
    countries = offices.map(&:country)
    unless countries.empty? || countries.include?(@world_location)
      countries.first
    end
  end
end
