class PoliticalContentIdentifier
  DEPENDENT_POLITICAL_FORMATS = [
    Consultation,
    Speech,
    NewsArticle,
  ].freeze

  ALWAYS_POLITICAL_FORMATS = [
    WorldLocationNewsArticle,
  ]

  POLITICAL_PUBLICATION_TYPES = [
    PublicationType::CorporateReport,
    PublicationType::ImpactAssessment,
    PublicationType::PolicyPaper,
  ].freeze

  attr_reader :edition
  def initialize(edition)
    @edition = edition
  end

  def self.political?(edition)
    new(edition).political?
  end

  def political?
    if political_format_or_type?
      is_associated_with_a_minister? || has_political_org?
    else
      always_political_format? || false
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

  def political_format_or_type?
    political_publication_type? || dependent_political_format?
  end

  def political_publication_type?
    edition.is_a?(Publication) &&
      !edition.statistics? &&
      POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
  end

  def dependent_political_format?
    DEPENDENT_POLITICAL_FORMATS.include?(edition.class)
  end

  def always_political_format?
    ALWAYS_POLITICAL_FORMATS.include?(edition.class)
  end
end
