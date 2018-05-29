class FindOrganisationDetails
  def find
    slugs = %w(
      highways-england
      highways-agency
      driver-and-vehicle-standards-agency
      driving-standards-agency
      vehicle-and-operator-services-agency
      department-for-transport
      maritime-and-coastguard-agency
      high-speed-two-limited
      traffic-commissioners
      office-of-rail-and-road
      office-of-rail-regulation
      office-for-low-emission-vehicles
      airports-commission
      passenger-focus
      transport-focus
      centre-for-connected-and-autonomous-vehicles
      disabled-persons-transport-advisory-committee
      british-transport-police-authority
      vehicle-certification-agency
      directly-operated-railways-limited
      northern-lighthouse-board
      trinity-house
      office-of-rail-and-road
      office-of-rail-regulation
      office-for-low-emission-vehicles
      airports-commission
      passenger-focus
      transport-focus
      centre-for-connected-and-autonomous-vehicles
      disabled-persons-transport-advisory-committee
      british-transport-police-authority
      vehicle-certification-agency
      directly-operated-railways-limited
      northern-lighthouse-board
      trinity-house
      civil-aviation-authority
      london-and-continental-railways-ltd
      railway-heritage-committee
      home-office
      uk-visas-and-immigration
      hm-revenue-customs
    )

    details = []
    slugs.map do |slug|
      org = Organisation.find_by(slug: slug)
      details << "- \"#{org['content_id']}\" \# #{org['name']}"
    end

    puts details
  end
end
