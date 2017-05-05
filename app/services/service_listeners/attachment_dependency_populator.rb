module ServiceListeners
  class AttachmentDependencyPopulator
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def populate!
      return unless edition.respond_to?(:html_attachments)
      edition.html_attachments.each do |attachment|
        extractor = Govspeak::ContactsExtractor.new(attachment.govspeak_content_body)
        extractor.contacts.each do |contact|
          unless edition.depended_upon_contacts.exists?(contact.id)
            edition.depended_upon_contacts << contact
          end
        end
      end
    end
  end
end
