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

    always_marked_political_by_system? || associated_with_a_minister? || associated_with_political_organisation?
  end

private

  def associated_with_a_minister?
    edition.can_be_marked_political_by_system_based_on_minister? && edition.is_associated_with_a_minister?
  end

  def always_marked_political_by_system?
    edition.always_marked_political_by_system?
  end

  def never_political_format?
    !edition.history_mode_enabled?
  end

  def associated_with_political_organisation?
    edition.can_be_marked_political_by_system_based_on_organisation? && has_political_org?
  end

  def has_political_org?
    edition.organisation_association_enabled? &&
      edition.organisations.where(political: true).any?
  end
end
