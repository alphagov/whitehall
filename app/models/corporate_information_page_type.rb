class CorporateInformationPageType
  include ActiveRecordLikeInterface

  attr_accessor :id, :title_template, :slug

  def self.find(slug)
    all.find {|type| type.slug == slug} or raise ActiveRecord::RecordNotFound
  end

  def title(organisation)
    title_template % (organisation.acronym || "the #{organisation.name}")
  end

  PersonalInformationCharter = create(
    id: 1, title_template: "Personal information charter", slug: "personal-information-charter"
  )
  PublicationScheme = create(
    id: 2, title_template: "Publication scheme", slug: "publication-scheme"
  )
  ComplaintsProcedure = create(
    id: 3, title_template: "Complaints procedure", slug: "complaints-procedure"
  )
  TermsOfReference = create(
    id: 4, title_template: "Terms of reference", slug: "terms-of-reference"
  )
  BoardMeetingPaper = create(
    id: 5, title_template: "Board meeting papers", slug: "board-meeting-papers"
  )
  Statistics = create(
    id: 6, title_template: "Statistics at %s", slug: "statistics"
  )
  Procurement = create(
    id: 7, title_template: "Procurement at %s", slug: "procurement"
  )
  Recruitment = create(
    id: 8, title_template: "Working for %s", slug: "recruitment"
  )
  OurEnergyUse = create(
    id: 9, title_template: "Our energy use", slug: "our-energy-use"
  )
  Membership = create(
    id: 10, title_template: "Membership", slug: "membership"
  )
end
