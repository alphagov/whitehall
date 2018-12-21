module Govspeak
  class ContactsExtractor
    def initialize(govspeak)
      @govspeak = govspeak
    end

    def contacts
      return [] if @govspeak.blank?

      # scan yields an array of capture groups for each match
      # so "[Contact:1] is now [Contact:2]" => [["1"], ["2"]]
      @govspeak.scan(EmbeddedContentPatterns::CONTACT).map { |capture|
        contact_id = capture.first
        Contact.find_by(id: contact_id)
      }.compact.uniq
    end
  end
end
