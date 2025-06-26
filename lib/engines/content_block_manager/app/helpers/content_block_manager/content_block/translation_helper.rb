module ContentBlockManager::ContentBlock::TranslationHelper
  def humanized_label(label, object_type = nil)
    translation_path = object_type ? "#{object_type}.#{label}" : label
    I18n.t("content_block_edition.details.labels.#{translation_path}", default: label.humanize.gsub("-", " "))
  end

  def translated_value(value)
    translation_path = "content_block_edition.details.values.#{value}"
    I18n.t(translation_path, default: value)
  end
end
