module ContentBlockManager::ContentBlock::TranslationHelper
  def humanized_label(relative_key:, root_object: nil)
    translation_path = root_object ? "#{root_object}.#{relative_key}" : relative_key

    I18n.t(
      "content_block_edition.details.labels.#{translation_path}",
      default: relative_key.humanize.gsub("-", " "),
    )
  end

  def translated_value(value)
    translation_path = "content_block_edition.details.values.#{value}"
    I18n.t(translation_path, default: value)
  end
end
