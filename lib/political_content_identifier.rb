class PoliticalContentIdentifier
  POLITICAL_PUBLICATION_TYPES = [
    PublicationType::CorporateReport,
    PublicationType::ImpactAssessment,
    PublicationType::InternationalTreaty,
    PublicationType::PolicyPaper,
    PublicationType::ResearchAndAnalysis,
  ].freeze

  def self.political?(edition)
    edition.is_associated_with_a_minister? || (is_political_format?(edition) && has_political_org?(edition))
  end

private

  def self.is_political_format?(edition)
    case edition
    when Consultation, Speech, NewsArticle, WorldLocationNewsArticle
      true
    when Publication
      POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
    else
      false
    end
  end

  def self.has_political_org?(edition)
    edition.can_be_related_to_organisations? &&
      edition.organisations.where(political: true).any?
  end
end
