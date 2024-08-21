class OrganisationBrandColour
  include ActiveRecordLikeInterface

  attr_accessor :id, :title, :class_name

  def self.find(class_name)
    all.detect { |type| type.class_name == class_name } || raise(ActiveRecord::RecordNotFound)
  end

  AttorneyGeneralsOffice = create!(
    id: 1,
    title: "Attorney General's Office",
    class_name: "attorney-generals-office",
  )
  CabinetOffice = create!(
    id: 2,
    title: "Cabinet Office",
    class_name: "cabinet-office",
  )
  DepartmentForBusinessInnovationSkills = create!(
    id: 3,
    title: "Department for Business, Innovation & Skills",
    class_name: "department-for-business-innovation-skills",
  )
  DepartmentForCommunitiesAndLocalGovernment = create!(
    id: 4,
    title: "Department for Communities and Local Government",
    class_name: "department-for-communities-and-local-government",
  )
  DepartmentForCultureMediaSport = create!(
    id: 5,
    title: "Department for Culture, Media & Sport",
    class_name: "department-for-culture-media-sport",
  )
  DepartmentForEducation = create!(
    id: 6,
    title: "Department for Education",
    class_name: "department-for-education",
  )
  DepartmentForEnvironmentFoodRuralAffairs = create!(
    id: 7,
    title: "Department for Environment, Food & Rural Affairs",
    class_name: "department-for-environment-food-rural-affairs",
  )
  DepartmentForInternationalDevelopment = create!(
    id: 8,
    title: "Department for International Development",
    class_name: "department-for-international-development",
  )
  DepartmentForTransport = create!(
    id: 9,
    title: "Department for Transport",
    class_name: "department-for-transport",
  )
  DepartmentForWorkPensions = create!(
    id: 10,
    title: "Department for Work & Pensions",
    class_name: "department-for-work-pensions",
  )
  DepartmentOfEnergyClimateChange = create!(
    id: 11,
    title: "Department of Energy & Climate Change",
    class_name: "department-of-energy-climate-change",
  )
  DepartmentOfHealth = create!(
    id: 12,
    title: "Department of Health",
    class_name: "department-of-health",
  )
  ForeignCommonwealthOffice = create!(
    id: 13,
    title: "Foreign & Commonwealth Office",
    class_name: "foreign-commonwealth-office",
  )
  HMGovernment = create!(
    id: 14,
    title: "HM Government",
    class_name: "hm-government",
  )
  HMRevenueCustoms = create!(
    id: 15,
    title: "HM Revenue & Customs",
    class_name: "hm-revenue-customs",
  )
  HMTreasury = create!(
    id: 16,
    title: "HM Treasury",
    class_name: "hm-treasury",
  )
  HomeOffice = create!(
    id: 17,
    title: "Home Office",
    class_name: "home-office",
  )
  MinistryOfDefence = create!(
    id: 18,
    title: "Ministry of Defence",
    class_name: "ministry-of-defence",
  )
  MinistryOfJustice = create!(
    id: 19,
    title: "Ministry of Justice",
    class_name: "ministry-of-justice",
  )
  NorthernIrelandOffice = create!(
    id: 20,
    title: "Northern Ireland Office",
    class_name: "northern-ireland-office",
  )
  OfficeOfTheAdvocateGeneralForScotland = create!(
    id: 21,
    title: "Office of the Advocate General for Scotland",
    class_name: "office-of-the-advocate-general-for-scotland",
  )
  OfficeOfTheLeaderOfTheHouseOfLords = create!(
    id: 22,
    title: "Office of the Leader of the House of Lords",
    class_name: "office-of-the-leader-of-the-house-of-lords",
  )
  ScotlandOffice = create!(
    id: 23,
    title: "Scotland Office",
    class_name: "scotland-office",
  )
  TheOfficeOfTheLeaderOfTheHouseOfCommons = create!(
    id: 24,
    title: "Office of the Leader of the House of Commons",
    class_name: "the-office-of-the-leader-of-the-house-of-commons",
  )
  UKExportFinance = create!(
    id: 25,
    title: "UK Export Finance",
    class_name: "uk-export-finance",
  )
  UKTradeInvestment = create!(
    id: 26,
    title: "UK Trade & Investment",
    class_name: "uk-trade-investment",
  )
  WalesOffice = create!(
    id: 27,
    title: "Wales Office",
    class_name: "wales-office",
  )
  CivilService = create!(
    id: 28,
    title: "Civil Service",
    class_name: "civil-service",
  )
  DepartmentForBusinessAndTrade = create!(
    id: 29,
    title: "Department for Business & Trade",
    class_name: "department-for-business-trade",
  )
  ForeignCommonwealthDevelopmentOffice = create!(
    id: 30,
    title: "Foreign, Commonwealth & Development Office",
    class_name: "foreign-commonwealth-development-office",
  )
  DepartmentForLevellingUpHousingAndCommunities = create!(
    id: 31,
    title: "Department for Levelling Up, Housing & Communities",
    class_name: "department-for-levelling-up-housing-and-communities",
  )
  DepartmentForScienceInnovationAndTechnology = create!(
    id: 32,
    title: "Department for Science, Innovation & Technology",
    class_name: "department-for-science-innovation-and-technology",
  )
  PrimeMinistersOffice10DowningStreet = create!(
    id: 33,
    title: "Prime Minister's Office, 10 Downing Street",
    class_name: "prime-ministers-office-10-downing-street",
  )
  MinistryOfHousingCommunitiesAndLocalGovernment = create!(
    id: 34,
    title: "Ministry of Housing, Communities & Local Government",
    class_name: "ministry-of-housing-communities-local-government",
  )
end
