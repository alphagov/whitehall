class GovspeakContactEmbedValidator < ActiveModel::Validator
  include Govspeak::ContactsExtractorHelpers

  def validate(record)
    govspeak_embedded_contact_ids(record.body).each do |contact_id|
      contact = Contact.find_by(id: contact_id)
      record.errors.add(:base, "Contact ID #{contact_id} doesn't exist") unless contact
    end
  end
end
