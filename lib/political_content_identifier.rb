class PoliticalContentIdentifier
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
      associated_with_political_organisation?
  end

private

  def stats_publication?
    edition.is_a?(Publication) && edition.statistics?
  end

  def associated_with_a_minister?
    edition.is_associated_with_a_minister?
  end

  def always_political_format?
    edition.configurable_document_type == "world_news_story"
  end

  def never_political_format?
    edition.is_a?(FatalityNotice) || stats_publication?
  end

  def associated_with_political_organisation?
    edition.can_be_marked_political_by_system_based_on_organisation? && has_political_org?
  end

  def has_political_org?
    edition.organisation_association_enabled? &&
      edition.organisations.where(political: true).any?
  end
end
