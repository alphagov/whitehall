module ContentBlockManager::ContentBlock::TranslationHelper
  def humanized_label(label, object_type = nil)
    translation_path = object_type ? "#{object_type}.#{label}" : label
    I18n.t("content_block_edition.details.labels.#{translation_path}", default: label.humanize.gsub("-", " "))
  end
end
