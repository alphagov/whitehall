class CorporateInformationPageType
  include ActiveRecordLikeInterface

  attr_accessor :id, :title, :slug

  def self.find(slug)
    all.find {|type| type.slug == slug} or raise ActiveRecord::RecordNotFound
  end

  PersonalInformationCharter = create(
    id: 1, title: "Personal information charter", slug: "personal-information-charter"
  )
  PublicationScheme = create(
    id: 2, title: "Publication scheme", slug: "publication-scheme"
  )
  ComplaintsProcedure = create(
    id: 3, title: "Complaints procedure", slug: "complaints-procedure"
  )
  TermsOfReference = create(
    id: 4, title: "Terms of reference", slug: "terms-of-reference"
  )
end
