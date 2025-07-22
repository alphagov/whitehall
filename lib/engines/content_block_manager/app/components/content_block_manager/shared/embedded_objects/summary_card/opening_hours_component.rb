class ContentBlockManager::Shared::EmbeddedObjects::SummaryCard::OpeningHoursComponent < ViewComponent::Base
  include ContentBlockManager::ContentBlock::TranslationHelper
  with_collection_parameter :opening_hours

  def initialize(opening_hours)
    @hours = opening_hours.fetch(:opening_hours)
  end

  def title
    "Opening hours"
  end

  def rows
    [{ key: "Hours", value: formatted_hours }]
  end

private

  def formatted_hours
    [
      @hours.fetch("day_from"),
      @hours.fetch("time_from").downcase,
      "to",
      @hours.fetch("day_to"),
      @hours.fetch("time_to").downcase,
    ].join(" ")
  end
end
