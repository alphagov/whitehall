class Embassy
  EmbassyOfficeTypes = [
    WorldwideOfficeType::BritishTradeACulturalOffice,
    WorldwideOfficeType::Consulate,
    WorldwideOfficeType::Embassy,
    WorldwideOfficeType::HighCommission,
  ]

  def self.filter_offices(worldwide_organisation)
    worldwide_organisation.offices.select { |o| embassy_office?(o) }
  end

  def self.embassy_office?(office)
    EmbassyOfficeTypes.include?(office.worldwide_office_type)
  end

  def initialize(world_location)
    @world_location = world_location
  end

  delegate :name, to: :@world_location

  def offices
    @world_location.worldwide_organisations.map { |org| self.class.filter_offices(org) }.flatten
  end

  def consular_services_organisations
    @world_location.worldwide_organisations.select do |org|
      self.class.filter_offices(org).any?
    end
  end

  def remote_services_country
    countries = offices.map(&:country)
    unless countries.empty? || countries.include?(@world_location)
      countries.first
    end
  end
end
