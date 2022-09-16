POLITICAL_ORG_SLUGS = %w[
  attorney-generals-office
  better-regulation-delivery-office
  cabinet-office
  department-for-business-enterprise-and-regulatory-reform
  department-for-business-innovation-skills
  department-for-children-schools-and-families
  department-for-communities-and-local-government
  department-for-constitutional-affairs
  department-for-culture-media-sport
  department-for-education
  department-for-education-and-skills
  department-for-environment-food-rural-affairs
  department-for-innovation-universities-and-skills
  department-for-international-development
  department-for-transport
  department-for-work-pensions
  department-of-constitutional-affairs
  department-of-energy-climate-change
  department-of-health
  department-of-national-heritage
  department-of-social-security
  department-of-the-environment-transport-and-the-regions
  department-of-trade-and-industry
  deputy-prime-ministers-office
  english-partnerships
  foreign-commonwealth-office
  government-equalities-office
  hm-treasury
  home-office
  homes-and-communities-agency
  housing-corporation
  immigration-enforcement
  infrastructure-uk
  law-officers-departments
  lord-chancellors-department
  ministry-of-defence
  ministry-of-justice
  northern-ireland-office
  office-for-low-emission-vehicles
  office-of-the-advocate-general-for-scotland
  the-office-of-the-leader-of-the-house-of-commons
  office-of-the-leader-of-the-house-of-lords
  open-public-services
  prime-ministers-office-10-downing-street
  renewable-fuels-agency
  scotland-office
  scottish-office
  the-shareholder-executive
  uk-export-finance
  wales-office
  welsh-office
].freeze

puts "Setting political flag on the following organisations:"
POLITICAL_ORG_SLUGS.each do |slug|
  organsation = Organisation.find_by(slug:)
  puts "\t#{organsation.name}"
  organsation.update!(political: true)
end
