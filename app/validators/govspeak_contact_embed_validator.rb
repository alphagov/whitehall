class GovspeakContactEmbedValidator < ActiveModel::Validator
  def validate(record)
    Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids.each do |contact_id|
      contact = Contact.find_by(id: contact_id)
      record.errors.add(:body, "Contact ID #{contact_id} doesn't exist") unless contact
    end

    if record.respond_to?(:html_attachments)
      record.html_attachments.each do |html_attachment|
        Govspeak::ContactsExtractor.new(html_attachment.body).extracted_contact_ids.each do |contact_id|
          contact = Contact.find_by(id: contact_id)
          error_message = I18n.t("activerecord.errors.models.edition.attributes.html_attachments.missing_contact_reference", html_attachment_title: html_attachment.title, contact_id: contact_id)
          record.errors.add(:html_attachments, error_message) unless contact
        end
      end
    end
  end
end
