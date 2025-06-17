module Govspeak
  class ContactsExtractor
    def initialize(govspeak)
      @govspeak = govspeak || ""
    end

    def valid_contacts
      extracted_contact_ids.map { |contact_id| Contact.find_by(id: contact_id) }.compact
    end

    def extracted_contact_ids
      # scan yields an array of capture groups for each match
      # so "[Contact:1] is now [Contact:2]" => [["1"], ["2"]]
      @govspeak.scan(EmbeddedContentPatterns::CONTACT).map { |capture|
        capture.first.to_i
      }.uniq
    end
  end
end
