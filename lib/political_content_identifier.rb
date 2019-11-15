class PoliticalContentIdentifier
  POTENTIALLY_POLITICAL_FORMATS = [
    Consultation,
    Speech,
    NewsArticle,
  ].freeze

  ALWAYS_POLITICAL_FORMATS = [
    WorldLocationNewsArticle,
  ].freeze

  NONPOLITICAL_BY_DEFAULT_FORMATS = [
    DetailedGuide,
    CorporateInformationPage,
  ].freeze

  POLITICAL_PUBLICATION_TYPES = [
    PublicationType::CorporateReport,
    PublicationType::ImpactAssessment,
    PublicationType::PolicyPaper,
  ].freeze

  NONPOLITICAL_BY_DEFAULT_PUBLICATION_TYPES = [
    PublicationType::Guidance,
    PublicationType::StatutoryGuidance,
    PublicationType::Form,
    PublicationType::Map,
    PublicationType::IndependentReport,
    PublicationType::InternationalTreaty,
    PublicationType::FoiRelease,
    PublicationType::Regulation,
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
    return true if always_political_format?

    (
      political_by_default_if_associated_with_a_minister? &&
      associated_with_a_minister?
    ) || (
      potentially_political_format? &&
      has_political_org?
    )
  end

private

  def associated_with_a_minister?
    edition.is_associated_with_a_minister?
  end

  def political_by_default_if_associated_with_a_minister?
    # Currently the non-political formats and publication types are
    # stored, so work out if the edition is non-political by default
    # if associated with a minister, then flip the boolean
    !(
      NONPOLITICAL_BY_DEFAULT_FORMATS.include?(edition.class) ||
      (edition.is_a?(Publication) &&
       NONPOLITICAL_BY_DEFAULT_PUBLICATION_TYPES.include?(edition.publication_type))
    )
  end

  def has_political_org?
    edition.can_be_related_to_organisations? &&
      edition.organisations.where(political: true).any?
  end

  def potentially_political_format?
    return true if POTENTIALLY_POLITICAL_FORMATS.include?(edition.class)

    edition.is_a?(Publication) &&
      POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
  end

  def always_political_format?
    ALWAYS_POLITICAL_FORMATS.include?(edition.class) ||
      (edition.is_a?(NewsArticle) && edition.world_news_story?)
  end

  def never_political_format?
    edition.is_a?(FatalityNotice) ||
      (edition.is_a?(Publication) && edition.statistics?)
  end
end
