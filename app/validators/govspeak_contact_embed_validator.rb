class GovspeakContactEmbedValidator < ActiveModel::Validator
  def validate(record)
    return if record.is_a?(Edition) && record.validation_context != :publish
    return if record.is_a?(HtmlAttachment) && skip_html_attachment_validation?(record)

    contact_ids = Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids
    invalid_contact_ids = contact_ids.reject { |id| Contact.exists?(id: id) }

    invalid_contact_ids.each { |contact_id| add_error_for_invalid_contact(record, contact_id) }
  end

private

  def add_error_for_invalid_contact(record, contact_id)
    case record
    when Edition
      record.errors.add(:body, "Contact ID #{contact_id} doesn't exist")
    when HtmlAttachment
      identifier = record.title.present? ? "'#{record.title}'" : record.id
      base_message = "HTML Attachment #{identifier} contains invalid contact reference: Contact ID #{contact_id} doesn't exist"

      record.errors.add(:base, "#{base_message}#{build_context_hint_for_attachment(record)}")
    else
      record.errors.add(:base, "Contact ID #{contact_id} doesn't exist")
    end
  end

  def build_context_hint_for_attachment(record)
    edition = record.respond_to?(:attachable) ? record.attachable : nil
    document = edition&.document
    return "" unless document&.editions&.any?

    if document.editions.count == 1
      ". You may need to create this contact first or use an existing contact ID"
    elsif document.ever_published_editions.exists?
      ". This contact may have been removed since the original publication"
    else
      ""
    end
  end

  def skip_html_attachment_validation?(record)
    return false unless record.is_a?(HtmlAttachment)

    edition = record.respond_to?(:attachable) ? record.attachable : nil
    return false unless edition.respond_to?(:draft?) && edition.draft?

    edition.document&.ever_published_editions&.exists? &&
      (record.instance_variable_get(:@created_during_draft) || record.new_record?)
  end
end
