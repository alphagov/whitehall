class ContentBlockManager::EmbeddedObjectImmutabilityCheck
  def initialize(edition:, field_reference:)
    @edition = edition
    @field_reference = field_reference
  end

  def can_be_deleted?(index)
    live_fields[index].blank?
  end

private

  def live_fields
    @live_fields ||= edition&.details&.dig(*field_reference) || []
  end

  attr_reader :edition, :field_reference
end
