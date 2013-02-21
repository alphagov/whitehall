module Whitehall
  class PublicationFilterOption
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :publication_types, :search_format_types
    attr_writer :edition_types

    def slug
      label.downcase.gsub(/[^a-z]+/, "-")
    end

    def edition_types
      @edition_types || []
    end

    def self.find_by_slug(slug)
      all.find { |pt| pt.slug == slug }
    end

    PolicyPaper = create(id: 1, label: "Policy papers", search_format_types: PublicationType::PolicyPaper.search_format_types, publication_types: [PublicationType::PolicyPaper])
    Consultation = create(id: 2, label: "Consultations", search_format_types: ['publicationesque-consultation'], publication_types: [PublicationType::Consultation])
    ImpactAssessment = create(id: 3, label: "Impact assessments", search_format_types: PublicationType::ImpactAssessment.search_format_types, publication_types: [PublicationType::ImpactAssessment])
    Guidance = create(id: 4, label: "Guidance", search_format_types: PublicationType::Guidance.search_format_types, publication_types: [PublicationType::Guidance])
    Form = create(id: 5, label: "Forms", search_format_types: PublicationType::Form.search_format_types, publication_types: [PublicationType::Form])
    Statistics = create(id: 6, label: "Statistics", search_format_types: ['publicationesque-statistics'], publication_types: [PublicationType::Statistics, PublicationType::NationalStatistics], edition_types: ["StatisticalDataSet"])
    ResearchAndAnalysis = create(id: 7, label: "Research and analysis", search_format_types: PublicationType::ResearchAndAnalysis.search_format_types, publication_types: [PublicationType::ResearchAndAnalysis])
    CorporateReport = create(id: 8, label: "Corporate reports", search_format_types: PublicationType::CorporateReport.search_format_types, publication_types: [PublicationType::CorporateReport])
    TransparencyData = create(id: 9, label: "Transparency data", search_format_types: PublicationType::TransparencyData.search_format_types, publication_types: [PublicationType::TransparencyData])
    Treaty = create(id: 10, label: "Treaties", search_format_types: PublicationType::Treaty.search_format_types, publication_types: [PublicationType::Treaty])
    FoiRelease = create(id: 11, label: "FOI releases", search_format_types: PublicationType::FoiRelease.search_format_types, publication_types: [PublicationType::FoiRelease])
    IndependentReport = create(id: 12, label: "Independent reports", search_format_types: PublicationType::IndependentReport.search_format_types, publication_types: [PublicationType::IndependentReport])
    Correspondence = create(id: 13, label: "Correspondence", search_format_types: PublicationType::Correspondence.search_format_types, publication_types: [PublicationType::Correspondence])
    PromotionalMaterial = create(id: 14, label: "Promotional material", search_format_types: PublicationType::PromotionalMaterial.search_format_types, publication_types: [PublicationType::PromotionalMaterial])
    Map = create(id: 15, label: "Maps", search_format_types: PublicationType::Map.search_format_types, publication_types: [PublicationType::Map])
  end
end
