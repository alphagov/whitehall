module StandardEdition::PublishingPrerequisites
  extend ActiveSupport::Concern

  included do
    validate :publishing_prerequisites_must_be_met, on: :publish
  end

  def unmet_publishing_prerequisites
    []
  end

private

  def publishing_prerequisites_must_be_met
    unmet_publishing_prerequisites.each { |message| errors.add(:base, message) }
  end
end
