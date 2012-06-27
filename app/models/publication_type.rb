require 'active_record_like_interface'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/inflections.rb'

class PublicationType
  include ActiveRecordLikeInterface

  attr_accessor :id, :singular_name, :plural_name, :use_discouraged

  def slug
    name.downcase.gsub(/[^a-z]+/, "-")
  end

  def self.primary
    all.reject { |pt| pt.use_discouraged }
  end

  def self.use_discouraged
    all.select { |pt| pt.use_discouraged }
  end

  PolicyPaper            = create(id: 1, singular_name: "Policy paper", plural_name: "Policy papers")
  ImpactAssessment       = create(id: 2, singular_name: "Impact assessment", plural_name: "Impact assessments")
  Guidance               = create(id: 3, singular_name: "Guidance", plural_name: "Guidance")
  Form                   = create(id: 4, singular_name: "Form", plural_name: "Forms")
  Statistics             = create(id: 5, singular_name: "Statistics", plural_name: "Statistics")
  ResearchAndAnalysis    = create(id: 6, singular_name: "Research and analysis", plural_name: "Research and analysis")
  CorporateReport        = create(id: 7, singular_name: "Corporate report", plural_name: "Corporate reports")

  # Less commonly used types whose use is discouraged
  CircularNewsletterOrBulletin = 
                           create(id: 8 , singular_name: "Circular, newsletter or bulletin", plural_name: "Circulars, newsletters and bulletins", use_discouraged: true)
  OfficialLetterOrNotice = create(id: 9 , singular_name: "Official letter or notice", plural_name: "Official letters and notices", use_discouraged: true)
  TransparencyData       = create(id: 10, singular_name: "Transparency data", use_discouraged: true)
  Treaty                 = create(id: 11, singular_name: "Treaty", plural_name: "Treaties", use_discouraged: true)
  FoiRelease             = create(id: 12, singular_name: "FOI release", plural_name: "FOI releases", use_discouraged: true)
  PromotionalMaterial    = create(id: 13, singular_name: "Promotional material", plural_name: "Promotional material", use_discouraged: true)
  IndependentReport      = create(id: 14, singular_name: "Independent report", plural_name: "Independent reports", use_discouraged: true)

  # Temporary to allow migration
  Unknown                = create(id: 999, singular_name: "Unknown", plural_name: "Unknown", use_discouraged: true)
end
