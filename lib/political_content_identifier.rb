class PoliticalContentIdentifier
  POTENTIALLY_POLITICAL_FORMATS = [
    Consultation,
    Speech,
    NewsArticle,
  ].freeze

  ALWAYS_POLITICAL_FORMATS = [
    WorldLocationNewsArticle,
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
    (edition.is_a?(Publication) && edition.statistics?)
  end

  def associated_with_a_minister?
    edition.is_associated_with_a_minister?
  end

  def has_political_org?
    edition.can_be_related_to_organisations? &&
      edition.organisations.where(political: true).any?
  end

  def potentially_political_format?
    potentially_political_publication? || POTENTIALLY_POLITICAL_FORMATS.include?(edition.class)
  end

  def potentially_political_publication?
    edition.is_a?(Publication) && political_publication_type?
  end

  def political_publication_type?
    POLITICAL_PUBLICATION_TYPES.include?(edition.publication_type)
  end

  def always_political_format?
    ALWAYS_POLITICAL_FORMATS.include?(edition.class) ||
      edition_is_a_world_news_story?
  end

  def never_political_format?
    edition.is_a?(FatalityNotice) || stats_publication?
  end

  def edition_is_a_world_news_story?
    edition.is_a?(NewsArticle) && edition.world_news_story?
  end
end
