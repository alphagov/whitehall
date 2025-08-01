class GovspeakContactEmbedValidator < ActiveModel::Validator
  PUBLISHED_STATES = %w[published superseded].freeze
  DRAFT_CREATION_METHODS = %w[process_associations_after_save create_draft].freeze

  def validate(record)
    return if should_skip_validation?(record)

    extract_contact_ids(record).each do |contact_id|
      next if contact_exists?(contact_id)

      record.errors.add(:base, build_error_message(record, contact_id))
    end
  end

private

  def should_skip_validation?(record)
    case record
    when Edition
      record.validation_context != :publish
    when HtmlAttachment
      skip_html_attachment_validation?(record)
    else
      false
    end
  end

  def skip_html_attachment_validation?(record)
    return false unless attached_to_draft_edition?(record)
    return false unless document_has_published_history?(record)

    record.new_record? || currently_creating_draft?
  end

  def attached_to_draft_edition?(record)
    record.attachable.is_a?(Edition) && record.attachable.draft?
  end

  def document_has_published_history?(record)
    document = record.attachable&.document
    return false unless document

    document.editions.where(state: PUBLISHED_STATES).exists?
  end

  def currently_creating_draft?
    caller.any? { |line| DRAFT_CREATION_METHODS.any? { |method| line.include?(method) } }
  end

  def extract_contact_ids(record)
    Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids
  end

  def contact_exists?(contact_id)
    Contact.exists?(id: contact_id)
  end

  def build_error_message(record, contact_id)
    base_message = "Contact ID #{contact_id} doesn't exist"

    case record
    when HtmlAttachment
      build_html_attachment_error(record, base_message)
    else
      base_message
    end
  end

  def build_html_attachment_error(record, base_message)
    identifier = attachment_identifier(record)
    context_hint = context_hint_for_attachment(record)
    "HTML Attachment #{identifier} invalid: #{base_message}#{context_hint}"
  end

  def attachment_identifier(record)
    record.title.present? ? "'#{record.title}'" : record.id
  end

  def context_hint_for_attachment(record)
    return "" unless record.attachable.is_a?(Edition)

    document = record.attachable.document
    return "" unless document

    if first_edition?(document)
      ". You may need to create this contact first or use an existing contact ID"
    elsif has_published_history?(document)
      ". This contact may have been removed since the original publication"
    else
      ""
    end
  end

  def first_edition?(document)
    document.editions.count == 1
  end

  def has_published_history?(document)
    document.editions.where(state: PUBLISHED_STATES).exists?
  end
end
