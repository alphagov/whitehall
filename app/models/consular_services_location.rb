class ConsularServicesLocation

  extend Forwardable

  def initialize(world_location)
    @world_location = world_location
  end

  def_delegator :@world_location, :name
  def_delegator :@world_location, :worldwide_organisations

  def offices
    organisation_offices.select { |office| embassy_high_commission_or_consulate?(office) } 
  end

  def consular_services?
    consular_services_country_names.any?
  end

  def remote_services_office
    if remote_services_country
      worldwide_organisations.map(&:offices).flatten.first.title
    end
  end

  def remote_services_country
    countries = consular_services_country_names
    unless countries.empty? or countries.include?(self.name)
      countries.first
    end
  end

  private

  def consular_services_country_names
    organisation_offices.map { |o| o.contact.country }.compact.map(&:name)
  end

  def organisation_offices
    worldwide_organisations.map(&:offices).flatten
  end

  def embassy_high_commission_or_consulate?(office)
    ["Embassy", "Consulate", "High Commission"].include?(office.worldwide_office_type.name)
  end
end
