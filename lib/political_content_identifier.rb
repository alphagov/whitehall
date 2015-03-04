class PoliticalContentIdentifier
  POLITICAL_PUBLICATION_TYPES = [
    PublicationType::CorporateReport,
    PublicationType::ImpactAssessment,
    PublicationType::InternationalTreaty,
    PublicationType::PolicyPaper,
    PublicationType::ResearchAndAnalysis,
  ].freeze

  attr_reader :edition
  def initialize(edition)
    @edition = edition
  end

  def self.political?(edition)
    new(edition).political?
  end

  def political?
    is_associated_with_a_minister? || (is_political_format? && has_political_org?)
  end

private

  def is_associated_with_a_minister?
    edition.is_associated_with_a_minister?
  end

  def is_political_format?
    case edition
    when Consultation, Speech, NewsArticle, WorldLocationNewsArticle
      true
    when Publication
      POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
    else
      false
    end
  end

  def has_political_org?
    edition.can_be_related_to_organisations? &&
      edition.organisations.where(political: true).any?
  end
end
