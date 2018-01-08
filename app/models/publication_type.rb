require 'active_record_like_interface'
require 'active_support/core_ext/object/blank.rb'
require 'active_support/core_ext/string/inflections.rb'

class PublicationType
  include ActiveRecordLikeInterface

  FORMAT_ADVICE = {
    1 => "<p>A policy paper explains the government's position on something. It doesn’t include instructions on how to carry out a task, only the policy itself and how it’ll be implemented.</p><p>Read the <a href=\"https://www.gov.uk/guidance/content-design/content-types#policy-paper\" target=\"_blank\">policy papers guidance</a> in full.</p>",
    2 => "<p>Cost-benefit analyses and other assessments of the impact of proposed initiatives, or changes to regulations or legislation.</p>",
    3 => "<p>Non-statutory guidance publications. Includes: manuals, handbooks and other documents that offer advice.</p><p>Do <em>not</em> use for: statutory guidance (use the “statutory guidance” publication type) or guidance about completing a form (attach to same publication as the form itself).</p>",
    4 => "<p>Pro-forma or form documents that need to be completed by the user. Can include guidance on how to fill in forms (ie no need to create a separate “guidance” publication for form instructions).</p>",
    5 => "<p>Statistics governed by the UK Statistics Authority and produced by members of the Government Statistical Service.</p>",
    6 => "<p>Research and evaluation papers. Can be conducted by government, commissioned by government or independent of government.</p>",
    7 => "<p>Publications about what an organisation does (eg business plans, annual reports, accounts), or any plans that affect the organisation (eg structural reform plans, efficiency reviews). Corporate reports are shown automatically on the organisation’s “What we do” page.</p>",
    8 => "<p>Ministerial or departmental responses (eg to campaign letters), announcements, or statements;regularly issued circulars or bulletins (eg fire service circulars), official correspondence to professionals (eg “Dear chief planning officer” letters);letters to individuals or organisations that are published to share with a wider audience than their original recipient;online versions of e-bulletins or newsletters.</p><p>Do <em>not</em> use for: minutes, agendas or other meeting papers. Attach them to relevant “policy detail”, “team” or “our governance” pages instead.</p>",
    10 => "<p>Information made available about departmental operations with the intent of making government more transparent.Includes organisation charts, staff survey results, departmental spending, salaries, contracts, meetings with ministers, etc.</p><p>Do <em>not</em> use for: FOI responses.</p>",
    12 => "<p>Responses to Freedom of Information requests. Ensure the title describes specifically what the request is about.</p>",
    13 => "<p>Leaflets, posters, fact sheets and marketing collateral.</p>",
    14 => "<p>Reviews, inquiries and other reports commissioned from or conducted by independent (ie non-governmental) bodies for consideration by the government.</p>",
    15 => "<p>Official Statistics that have been produced in accordance with the Code of Practice for Official Statistics, which is indicated using the National Statistics quality mark.</p>",
    17 => "<p>Drawn maps and geographical data.</p>",
    18 => "<p>Treaties and memoranda of understanding between the UK and other nations.</p>",
    19 => "<p>Guidance which relevant users are legally obliged to follow. (For non-statutory guidance publications, use the “guidance” sub-type).</p>",
    20 => "<p>Permit and licence applications published temporarily for public awareness.</p>",
    21 => "<p>Formal decisions by tribunals, regulators or adjudicators (including courts and Secretaries of State).</p>",
    22 => "<p>Regulations imposed by an independent regulatory authority only.</p><p>Do <em>not</em> use for: statutory guidance.</p>",
    999 => "<p>DO NOT USE. This is a legacy category for content created before sub-types existed.</p>",
    1000 => "<p>DO NOT USE. This is a holding category for content that has been imported automatically.</p>",
  }.to_json.freeze

  attr_accessor :id, :singular_name, :plural_name, :prevalence, :access_limited_by_default, :key, :additional_search_format_types, :detailed_format

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
    [OfficialStatistics, NationalStatistics]
  end

  def slug
    plural_name.downcase.gsub(/[^a-z]+/, "-")
  end

  def access_limited_by_default?
    !!self.access_limited_by_default
  end

  def search_format_types
    [primary_search_format_type] + additional_search_format_types
  end

  def primary_search_format_type
    'publication-' + self.singular_name.parameterize
  end

  def additional_search_format_types
    @additional_search_format_types || []
  end

  def genus_key
    'publication'
  end

  PolicyPaper            = create(id: 1, key: "policy_paper", singular_name: "Policy paper", plural_name: "Policy papers", prevalence: :primary)
  ImpactAssessment       = create(id: 2, key: "impact_assessment", singular_name: "Impact assessment", plural_name: "Impact assessments", prevalence: :primary)
  Guidance               = create(id: 3, key: "guidance", singular_name: "Guidance", plural_name: "Guidance", prevalence: :primary, additional_search_format_types: ['publicationesque-guidance', 'publication-statutory_guidance'])
  StatutoryGuidance      = create(id: 19, key: "statutory_guidance", singular_name: "Statutory guidance", plural_name: "Statutory guidance", prevalence: :primary, additional_search_format_types: ['publicationesque-guidance'])
  Form                   = create(id: 4, key: "form", singular_name: "Form", plural_name: "Forms", prevalence: :primary)
  OfficialStatistics     = create(id: 5, key: "official_statistics", singular_name: "Official Statistics", plural_name: "Official Statistics", prevalence: :primary, access_limited_by_default: true, additional_search_format_types: ['publicationesque-statistics'], detailed_format: "statistics")
  NationalStatistics     = create(id: 15, key: "national_statistics", singular_name: "National Statistics", plural_name: "National Statistics", prevalence: :primary, access_limited_by_default: true, additional_search_format_types: ['publicationesque-statistics'], detailed_format: "statistics-national-statistics")
  ResearchAndAnalysis    = create(id: 6, key: "research", singular_name: "Research and analysis", plural_name: "Research and analysis", prevalence: :primary)
  CorporateReport        = create(id: 7, key: "corporate_report", singular_name: "Corporate report", plural_name: "Corporate reports", prevalence: :primary)
  Map                    = create(id: 17, key: "map", singular_name: "Map", plural_name: "Maps", prevalence: :primary)

  # Less common
  TransparencyData       = create(id: 10, key: "transparency", singular_name: "Transparency data", plural_name: "Transparency data", prevalence: :less_common)
  FoiRelease             = create(id: 12, key: "foi_release", singular_name: "FOI release", plural_name: "FOI releases", prevalence: :less_common)
  IndependentReport      = create(id: 14, key: "independent_report", singular_name: "Independent report", plural_name: "Independent reports", prevalence: :less_common)
  InternationalTreaty    = create(id: 18, key: "international_treaty", singular_name: "International treaty", plural_name: "International treaties", prevalence: :less_common)
  Notice                 = create(id: 20, key: "notice", singular_name: "Notice", plural_name: "Notices", prevalence: :less_common)
  Decision               = create(id: 21, key: "decision", singular_name: "Decision", plural_name: "Decisions", prevalence: :less_common)

  # Use is discouraged
  Correspondence         = create(id: 8, key: "correspondence", singular_name: "Correspondence", plural_name: "Correspondence", prevalence: :discouraged)
  PromotionalMaterial    = create(id: 13, key: "promotional", singular_name: "Promotional material", plural_name: "Promotional material", prevalence: :discouraged)
  Regulation             = create(id: 22, key: "regulation", singular_name: "Regulation", plural_name: "Regulations", prevalence: :discouraged)

  # Temporary to allow migration
  Unknown                = create(id: 999, key: "publication", singular_name: "Publication", plural_name: "Publication", prevalence: :migration)

  # For imported publications with a blank publication_type field
  ImportedAwaitingType   = create(id: 1000, key: "imported", singular_name: "Imported - awaiting type", plural_name: "Imported - awaiting type", prevalence: :migration)
end
