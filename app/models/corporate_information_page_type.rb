class CorporateInformationPageType
  include ActiveRecordLikeInterface

  attr_accessor :id, :title_template, :slug, :menu_heading

  def self.find(slug)
    all.detect { |type| type.slug == slug } || raise(ActiveRecord::RecordNotFound)
  end

  def key
    # RegisterableEdition expects model_name_type instances to have a `key`
    # attribute: Publication and WorldLocation for example define this to have
    # different subtype kinds. Our use of _type is slightly different and all
    # types have the same kind, ie CIP.
    'corporate_information_page'
  end

  def title(organisation)
    organisation_name = if organisation.respond_to?(:acronym) && organisation.acronym.present?
                          organisation.acronym
                        else
                          organisation.name
                        end
    translation_key = slug.tr('-', '_')
    I18n.t("corporate_information_page.type.title.#{translation_key}", organisation_name: organisation_name)
  end

  def self.by_menu_heading(menu_heading)
    all.select { |t| t.menu_heading == menu_heading }
  end

  def display_type_key
    slug.tr("-", "_")
  end

  PersonalInformationCharter = create(
    id: 1, slug: "personal-information-charter", menu_heading: :other,
  )
  PublicationScheme = create(
    id: 2, slug: "publication-scheme", menu_heading: :other,
  )
  ComplaintsProcedure = create(
    id: 3, slug: "complaints-procedure", menu_heading: :our_information,
  )
  TermsOfReference = create(
    id: 4, slug: "terms-of-reference", menu_heading: :our_information,
  )
  OurGovernance = create(
    id: 5, slug: "our-governance", menu_heading: :our_information,
  )
  Statistics = create(
    id: 6, slug: "statistics", menu_heading: :our_information,
  )
  Procurement = create(
    id: 7, slug: "procurement", menu_heading: :jobs_and_contracts,
  )
  Recruitment = create(
    id: 8, slug: "recruitment", menu_heading: :jobs_and_contracts,
  )
  OurEnergyUse = create(
    id: 9, slug: "our-energy-use", menu_heading: :our_information,
  )
  Membership = create(
    id: 10, slug: "membership", menu_heading: :our_information,
  )
  WelshLanguageScheme = create(
    id: 11, slug: "welsh-language-scheme", menu_heading: :other,
  )
  EqualityAndDiversity = create(
    id: 12, slug: "equality-and-diversity", menu_heading: :our_information,
  )
  PetitionsAndCampaigns = create(
    id: 13, slug: "petitions-and-campaigns", menu_heading: :our_information,
  )
  Research = create(
    id: 14, slug: "research", menu_heading: :our_information
  )
  OfficeAccessAndOpeningTimes = create(
    id: 15, slug: "access-and-opening", menu_heading: :our_information
  )
  StaffNewsAndInformation = create(
    id: 16, slug: "staff-update", menu_heading: :other
  )
  MediaEnquiries = create(
    id: 17, slug: 'media-enquiries', menu_heading: :our_information
  )
  SocialMediaUse = create(
    id: 18, slug: 'social-media-use', menu_heading: :other
  )
  AboutOurServices = create(
    id: 19, slug: 'about-our-services', menu_heading: :other
  )
  AboutUs = create(
    id: 20, slug: 'about', menu_heading: :other
  )
end
