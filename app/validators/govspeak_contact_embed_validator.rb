class GovspeakContactEmbedValidator < ActiveModel::Validator
  def validate(record)
    Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids.each do |contact_id|
      contact = Contact.find_by(id: contact_id)
      record.errors.add(:base, "Contact ID #{contact_id} doesn't exist") unless contact
    end
  end
end
