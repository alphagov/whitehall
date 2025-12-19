class PoliticalContentIdentifier
  POTENTIALLY_POLITICAL_FORMATS = [
    CallForEvidence,
    CaseStudy,
    Consultation,
    Speech,
  ].freeze

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
    return false if never_political_format?

    associated_with_a_minister? ||
      always_political_format? ||
      (potentially_political_format? && has_political_org?)
  end

private

  def stats_publication?
    edition.is_a?(Publication) && edition.statistics?
  end

  def associated_with_a_minister?
    edition.is_associated_with_a_minister?
  end

  def has_political_org?
    edition.organisation_association_enabled? &&
      edition.organisations.where(political: true).any?
  end

  def potentially_political_format?
    potentially_political_publication? ||
      potentially_political_standard_edition? ||
      POTENTIALLY_POLITICAL_FORMATS.include?(edition.class)
  end

  def potentially_political_standard_edition?
    edition.is_a?(StandardEdition) &&
      %w[news_story press_release].include?(edition.configurable_document_type)
  end

  def potentially_political_publication?
    edition.is_a?(Publication) && political_publication_type?
  end

  def political_publication_type?
    POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
  end

  def always_political_format?
    edition.is_a?(StandardEdition) &&
      edition.configurable_document_type == "world_news_story"
  end

  def never_political_format?
    edition.is_a?(FatalityNotice) || stats_publication?
  end
end
