class ContentBlockManager::ContentBlockEdition::Details::Fields::HiddenTitleComponent < ContentBlockManager::ContentBlockEdition::Details::Fields::BaseComponent

  private

  def value
    @value ||= generated_value
  end

  def generated_value
    current_count = content_block_edition.details[object_id]&.values&.count || 0
    "#{object_id.singularize.humanize} #{current_count + 1}"
  end
end
