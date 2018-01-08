class Embassy
  extend Forwardable

  def initialize(world_location)
    @world_location = world_location
  end

  def_delegator :@world_location, :name

  def self.filter_offices(worldwide_organisation)
    worldwide_organisation.offices.select { |o| embassy_office?(o) }
  end

  def offices
    @world_location.worldwide_organisations.map { |org| self.class.filter_offices(org) }.flatten
  end

  def consular_services_organisations
    @world_location.worldwide_organisations.select do |org|
      self.class.filter_offices(org).any?
    end
  end

  def remote_services_country
    offices = consular_services_organisations.map(&:offices).flatten
    countries = offices.map(&:country)
    unless countries.empty? or countries.include?(@world_location)
      countries.first
    end
  end

  def self.embassy_office?(office)
    [
      "British Trade and Cultural Office",
      "Consulate",
      "Embassy",
      "High Commission",
    ].include?(office.worldwide_office_type.name)
  end
end
