class GovspeakContactEmbedValidator < ActiveModel::Validator
  def validate(record)
    contact_ids = Govspeak::ContactsExtractor.new(record.body).extracted_contact_ids
    invalid_contact_ids = contact_ids.reject { |id| Contact.exists?(id: id) }

    invalid_contact_ids.each do |contact_id|
      record.errors.add(:body, "Contact ID #{contact_id} doesn't exist", contact_id: contact_id.to_s, error: :invalid_contact)
    end
  end
end
