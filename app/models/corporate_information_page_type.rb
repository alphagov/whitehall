class CorporateInformationPageType
  include ActiveRecordLikeInterface

  attr_accessor :id, :title_template, :slug, :menu_heading

  def self.find(slug)
    all.detect { |type| type.slug == slug } or raise ActiveRecord::RecordNotFound
  end

  def self.find_by_title(title)
    all.detect { |type| type.title_template == title } or raise ActiveRecord::RecordNotFound
  end

  def title(organisation)
    title_template % (organisation.respond_to?(:acronym) && organisation.acronym || "#{organisation.name}")
  end

  def self.by_menu_heading(menu_heading)
    all.select { |t| t.menu_heading == menu_heading }
  end

  def display_type_key
    slug.gsub("-", "_")
  end

  PersonalInformationCharter = create(
    id: 1, title_template: "Personal information charter", slug: "personal-information-charter", menu_heading: :other,
  )
  PublicationScheme = create(
    id: 2, title_template: "Publication scheme", slug: "publication-scheme", menu_heading: :other,
  )
  ComplaintsProcedure = create(
    id: 3, title_template: "Complaints procedure", slug: "complaints-procedure", menu_heading: :our_information,
  )
  TermsOfReference = create(
    id: 4, title_template: "Terms of reference", slug: "terms-of-reference", menu_heading: :our_information,
  )
  OurGovernance = create(
    id: 5, title_template: "Our governance", slug: "our-governance", menu_heading: :our_information,
  )
  Statistics = create(
    id: 6, title_template: "Statistics at %s", slug: "statistics", menu_heading: :our_information,
  )
  Procurement = create(
    id: 7, title_template: "Procurement at %s", slug: "procurement", menu_heading: :jobs_and_contracts,
  )
  Recruitment = create(
    id: 8, title_template: "Working for %s", slug: "recruitment", menu_heading: :jobs_and_contracts,
  )
  OurEnergyUse = create(
    id: 9, title_template: "Our energy use", slug: "our-energy-use", menu_heading: :our_information,
  )
  Membership = create(
    id: 10, title_template: "Membership", slug: "membership", menu_heading: :our_information,
  )
  WelshLanguageScheme = create(
    id: 11, title_template: "Welsh language scheme", slug: "welsh-language-scheme", menu_heading: :other,
  )
  EqualityAndDiversity = create(
    id: 12, title_template: "Equality and diversity", slug: "equality-and-diversity", menu_heading: :our_information,
  )
  PetitionsAndCampaigns = create(
    id: 13, title_template: "Petitions and campaigns", slug: "petitions-and-campaigns", menu_heading: :our_information,
  )
  Research = create(
    id: 14, title_template: "Research at %s", slug: "research", menu_heading: :our_information
  )
  OfficeAccessAndOpeningTimes = create(
    id: 15, title_template: "Office access and opening times", slug: "access-and-opening", menu_heading: :our_information
  )
  StaffNewsAndInformation = create(
    id: 16, title_template: "Staff news and information", slug: "staff-update", menu_heading: :other
  )
  MediaEnquiries = create(
    id: 17, title_template: "Media enquiries", slug: 'media-enquiries', menu_heading: :our_information
  )
  SocialMediaUse = create(
    id: 18, title_template: "Social media use", slug: 'social-media-use', menu_heading: :other
  )
  AboutOurServices = create(
    id: 19, title_template: "About our services", slug: 'about-our-services', menu_heading: :other
  )
end
