module Whitehall
  class PublicationFilterOption
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :publication_types, :search_format_types, :group_key
    attr_writer :edition_types, :slug

    def slug
      @slug || label.downcase.gsub(/[^a-z]+/, "-")
    end

    def edition_types
      @edition_types || []
    end

    def self.find_by_slug(slug)
      all.detect { |pt| pt.slug == slug }
    end

    def self.find_by_search_format_types(format_types)
      all.detect do |at|
        format_types.any? {|t| at.search_format_types.include?(t)}
      end
    end

    PolicyPaper = create(id: 1, label: "Policy papers", search_format_types: PublicationType::PolicyPaper.search_format_types, publication_types: [PublicationType::PolicyPaper])
    Consultation = create(id: 2, slug: "consultations", label: "All consultations", search_format_types: ['publicationesque-consultation'], publication_types: [PublicationType::Consultation], group_key: 'consultations')
    OpenConsultation = create(id: 3, label: "Open consultation", search_format_types: ['consultation-open'], publication_types: [PublicationType::Consultation], group_key: 'consultations')
    ClosedConsultation = create(id: 4, label: "Closed consultation", search_format_types: ['consultation-closed', 'consultation-outcome'], publication_types: [PublicationType::Consultation], group_key: 'consultations')
    OutcomeConsultation = create(id: 5, label: "Consultation outcome", search_format_types: ['consultation-outcome'], publication_types: [PublicationType::Consultation], group_key: 'consultations')
    ImpactAssessment = create(id: 6, label: "Impact assessments", search_format_types: PublicationType::ImpactAssessment.search_format_types, publication_types: [PublicationType::ImpactAssessment])
    Guidance = create(id: 7, label: "Guidance", search_format_types: PublicationType::Guidance.search_format_types, publication_types: [PublicationType::Guidance])
    Form = create(id: 8, label: "Forms", search_format_types: PublicationType::Form.search_format_types, publication_types: [PublicationType::Form])
    Statistics = create(id: 9, label: "Statistics", search_format_types: ['publicationesque-statistics'], publication_types: [PublicationType::Statistics, PublicationType::NationalStatistics], edition_types: ["StatisticalDataSet"])
    ResearchAndAnalysis = create(id: 10, label: "Research and analysis", search_format_types: PublicationType::ResearchAndAnalysis.search_format_types, publication_types: [PublicationType::ResearchAndAnalysis])
    CorporateReport = create(id: 11, label: "Corporate reports", search_format_types: PublicationType::CorporateReport.search_format_types, publication_types: [PublicationType::CorporateReport])
    TransparencyData = create(id: 12, label: "Transparency data", search_format_types: PublicationType::TransparencyData.search_format_types, publication_types: [PublicationType::TransparencyData])
    FoiRelease = create(id: 13, label: "FOI releases", search_format_types: PublicationType::FoiRelease.search_format_types, publication_types: [PublicationType::FoiRelease])
    IndependentReport = create(id: 14, label: "Independent reports", search_format_types: PublicationType::IndependentReport.search_format_types, publication_types: [PublicationType::IndependentReport])
    Correspondence = create(id: 15, label: "Correspondence", search_format_types: PublicationType::Correspondence.search_format_types, publication_types: [PublicationType::Correspondence])
    PromotionalMaterial = create(id: 16, label: "Promotional material", search_format_types: PublicationType::PromotionalMaterial.search_format_types, publication_types: [PublicationType::PromotionalMaterial])
    Map = create(id: 17, label: "Maps", search_format_types: PublicationType::Map.search_format_types, publication_types: [PublicationType::Map])
  end
end
