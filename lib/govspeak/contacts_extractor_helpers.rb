module Govspeak
  module ContactsExtractorHelpers
    def govspeak_embedded_contacts(govspeak)
      ContactsExtractor.new(govspeak).contacts
    end
  end
end
