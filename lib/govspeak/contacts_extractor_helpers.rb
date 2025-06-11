module Govspeak
  module ContactsExtractorHelpers
    def govspeak_embedded_contacts(govspeak)
      ContactsExtractor.new(govspeak).valid_contacts
    end
  end
end
