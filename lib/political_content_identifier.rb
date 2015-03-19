class PoliticalContentIdentifier
  POLITICAL_FORMATS = [
    Consultation,
    Speech,
    NewsArticle,
    WorldLocationNewsArticle,
  ].freeze

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
    if can_be_political?
      is_associated_with_a_minister? || has_political_org?
    else
      false
    end
  end

private

  def is_associated_with_a_minister?
    edition.is_associated_with_a_minister?
  end

  def has_political_org?
    edition.can_be_related_to_organisations? &&
      edition.organisations.where(political: true).any?
  end

  def can_be_political?
    political_publication_type? || political_format?
  end

  def political_publication_type?
    edition.is_a?(Publication) &&
      !edition.statistics? &&
      POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
  end

  def political_format?
    POLITICAL_FORMATS.include?(edition.class)
  end
end
