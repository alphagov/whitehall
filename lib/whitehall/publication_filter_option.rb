module Whitehall
  class PublicationFilterOption
    include ActiveRecordLikeInterface

    attr_accessor :id, :label, :publication_types
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

    PolicyPaper = create(id: 1, label: "Policy papers", publication_types: [PublicationType::PolicyPaper])
    Consultation = create(id: 2, label: "Consultations", publication_types: [PublicationType::Consultation])
    ImpactAssessment = create(id: 3, label: "Impact assessments", publication_types: [PublicationType::ImpactAssessment])
    Guidance = create(id: 4, label: "Guidance", publication_types: [PublicationType::Guidance])
    Form = create(id: 5, label: "Forms", publication_types: [PublicationType::Form])
    Statistics = create(id: 6, label: "Statistics", publication_types: [PublicationType::Statistics, PublicationType::NationalStatistics], edition_types: ["StatisticalDataSet"])
    ResearchAndAnalysis = create(id: 7, label: "Research and analysis", publication_types: [PublicationType::ResearchAndAnalysis])
    CorporateReport = create(id: 8, label: "Corporate reports", publication_types: [PublicationType::CorporateReport])
    TransparencyData = create(id: 9, label: "Transparency data", publication_types: [PublicationType::TransparencyData])
    Treaty = create(id: 10, label: "Treaties", publication_types: [PublicationType::Treaty])
    FoiRelease = create(id: 11, label: "FOI releases", publication_types: [PublicationType::FoiRelease])
    IndependentReport = create(id: 12, label: "Independent reports", publication_types: [PublicationType::IndependentReport])
    Correspondence = create(id: 13, label: "Correspondence", publication_types: [PublicationType::Correspondence])
    PromotionalMaterial = create(id: 14, label: "Promotional material", publication_types: [PublicationType::PromotionalMaterial])
  end
end
