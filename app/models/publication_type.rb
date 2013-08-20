require 'active_record_like_interface'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/inflections.rb'

class PublicationType
  include ActiveRecordLikeInterface

  attr_accessor :id, :singular_name, :plural_name, :prevalence, :access_limited_by_default, :key

  def self.access_limitable
    all.select(&:access_limited_by_default?)
  end

  def self.by_prevalence
    all.group_by { |type| type.prevalence }
  end

  def self.ordered_by_prevalence
    primary + less_common + use_discouraged + migration
  end

  def self.find_by_slug(slug)
    all.detect { |type| type.slug == slug }
  end

  def self.find_by_plural_name(plural_name)
    all.detect { |type| type.plural_name == plural_name }
  end

  def self.primary
    by_prevalence[:primary]
  end

  def self.less_common
    by_prevalence[:less_common]
  end

  def self.use_discouraged
    by_prevalence[:discouraged]
  end

  def self.migration
    by_prevalence[:migration]
  end

  def self.statistical
    [Statistics, NationalStatistics]
  end

  def slug
    plural_name.downcase.gsub(/[^a-z]+/, "-")
  end

  def access_limited_by_default?
    !! self.access_limited_by_default
  end

  def search_format_types
    types = ['publication-' + self.singular_name.parameterize]
    types += ['publication-statistics', 'publicationesque-statistics'] if PublicationType.statistical.include? self
    types << 'publicationesque-consultation' if self == Consultation
    types
  end

  PolicyPaper            = create(id: 1, key: "policy_paper", singular_name: "Policy paper", plural_name: "Policy papers", prevalence: :primary)
  Consultation           = create(id: 16, key: "consultation", singular_name: "Consultation", plural_name: "Consultations", prevalence: :primary)

  ImpactAssessment       = create(id: 2, key: "impact_assessment", singular_name: "Impact assessment", plural_name: "Impact assessments", prevalence: :primary)
  Guidance               = create(id: 3, key: "guidance", singular_name: "Guidance", plural_name: "Guidance", prevalence: :primary)
  Form                   = create(id: 4, key: "form", singular_name: "Form", plural_name: "Forms", prevalence: :primary)
  Statistics             = create(id: 5, key: "statistics", singular_name: "Statistics", plural_name: "Statistics", prevalence: :primary, access_limited_by_default: true)
  NationalStatistics     = create(id: 15, key: "national_statistics", singular_name: "Statistics - national statistics", plural_name: "Statistics - national statistics", prevalence: :primary, access_limited_by_default: true)
  ResearchAndAnalysis    = create(id: 6, key: "research", singular_name: "Research and analysis", plural_name: "Research and analysis", prevalence: :primary)
  CorporateReport        = create(id: 7, key: "corporate_report", singular_name: "Corporate report", plural_name: "Corporate reports", prevalence: :primary)
  Map                    = create(id: 17, key: "map", singular_name: "Map", plural_name: "Maps", prevalence: :primary)

  # Less common
  TransparencyData       = create(id: 10, key: "transparency", singular_name: "Transparency data", plural_name: "Transparency data", prevalence: :less_common)
  FoiRelease             = create(id: 12, key: "foi_release", singular_name: "FOI release", plural_name: "FOI releases", prevalence: :less_common)
  IndependentReport      = create(id: 14, key: "independent_report", singular_name: "Independent report", plural_name: "Independent reports", prevalence: :less_common)
  InternationalTreaty    = create(id: 18, key: "international_treaty", singular_name: "International treaty", plural_name: "International treaties", prevalence: :less_common)

  # Use is discouraged
  Correspondence         = create(id: 8 , key: "correspondence", singular_name: "Correspondence", plural_name: "Correspondence", prevalence: :discouraged)
  PromotionalMaterial    = create(id: 13, key: "promotional", singular_name: "Promotional material", plural_name: "Promotional material", prevalence: :discouraged)

  # Temporary to allow migration
  Unknown                = create(id: 999, key: "publication", singular_name: "Publication", plural_name: "Publication", prevalence: :migration)

  # For imported publications with a blank publication_type field
  ImportedAwaitingType   = create(id: 1000, key: "imported", singular_name: "Imported - awaiting type", plural_name: "Imported - awaiting type", prevalence: :migration)
end
