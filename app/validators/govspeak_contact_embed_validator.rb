class GovspeakContactEmbedValidator < ActiveModel::Validator
  def validate(record)
    return if record.is_a?(Edition) && record.validation_context != :publish

    Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids.each do |contact_id|
      next if Contact.exists?(id: contact_id)
      
      record.errors.add(:base, build_error_message(record, contact_id))
    end
  end

private

  def build_error_message(record, contact_id)
    case record
    when HtmlAttachment
      identifier = record.title.present? ? "'#{record.title}'" : record.id
      "HTML Attachment #{identifier} invalid: Contact ID #{contact_id} doesn't exist"
    else
      "Contact ID #{contact_id} doesn't exist"
    end
  end
end
