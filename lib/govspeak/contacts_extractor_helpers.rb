module Govspeak
  module ContactsExtractorHelpers
    def govspeak_embedded_contacts(govspeak)
      ContactsExtractor.new(govspeak).valid_contacts
    end

    def govspeak_embedded_contact_ids(govspeak)
      ContactsExtractor.new(govspeak).extracted_contact_ids
    end
  end
end
