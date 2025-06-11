module DataHygiene
  class GovspeakContactEmbedValidator
    include Govspeak::ContactsExtractorHelpers

    def initialize(body)
      @body = body
    end

    def errors
      govspeak_embedded_contact_ids(@body).map { |contact_id|
        contact = Contact.find_by(id: contact_id)
        { contact_id:, message: "Contact ID #{contact_id} doesn't exist" } unless contact
      }.compact
    end
  end
end
