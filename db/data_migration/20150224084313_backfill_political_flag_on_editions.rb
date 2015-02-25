# As per https://docs.google.com/a/digital.cabinet-office.gov.uk/spreadsheets/d/1412V79VMtpfZWNMYJhV7A2QFDKvUdseRtnA35bm-gmY/edit#gid=1194852478
#
# Exceptions at time of writing:
# - Blog posts are not stored in Whitehall
# - Annual reports are covered under corporate reports
# - Government responses, press releases and news stories are covered under news articles

POLITICAL_PUBLICATION_TYPES = [
  PublicationType::ImpactAssessment,
  PublicationType::InternationalTreaty,
  PublicationType::PolicyPaper,
  PublicationType::ResearchAndAnalysis,
  PublicationType::CorporateReport
].freeze

POLITICAL_ORGS = %w[
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
  department-of-inland-revenue
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

def has_minister?(edition)
  (edition.can_be_associated_with_ministers? && edition.ministerial_roles.any?) ||
    edition.try(:role_appointment).try(:role).is_a?(MinisterialRole)
end

def political_format?(edition)
  case edition
  when Consultation, Speech, NewsArticle, WorldLocationNewsArticle
    true
  when Publication
    POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
  else
    false
  end
end

def has_political_org?(edition)
  edition.can_be_related_to_organisations? &&
    edition.organisations.where(slug: POLITICAL_ORGS).any?
end

index = 0
edition_scope = Edition.where(state: ["published","draft","archived"])
edition_count = edition_scope.count

edition_scope.find_each do |edition|
  if has_minister?(edition) || (political_format?(edition) && has_political_org?(edition))
    edition.update_attribute(:political, true)
  end

  index += 1

  Rails.logger.info("Processed #{index} of #{edition_count} editions (#{(index.to_f/edition_count.to_f)*100}%)") if index % 1000 == 0
end
