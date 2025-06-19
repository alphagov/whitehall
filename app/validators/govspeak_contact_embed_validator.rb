class GovspeakContactEmbedValidator < ActiveModel::Validator
  def validate(record)
    Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids.each do |contact_id|
      contact = Contact.find_by(id: contact_id)
      record.errors.add(:base, "Contact ID #{contact_id} doesn't exist") unless contact
    end

    if record.respond_to?(:html_attachments)
      record.html_attachments.each do |html_attachment|
        Govspeak::ContactsExtractor.new(html_attachment.body).extracted_contact_ids.each do |contact_id|
          contact = Contact.find_by(id: contact_id)
          html_attachment.errors.add(:base, "Contact ID #{contact_id} doesn't exist") unless contact
        end
      end
    end
  end
end
