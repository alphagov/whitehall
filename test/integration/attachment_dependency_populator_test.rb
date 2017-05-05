require "test_helper"

class AttachmentDependencyPopulatorTest < ActiveSupport::TestCase
  def test_contact_added_to_edition
    publication = create(:publication)
    contact = create(:contact)
    attachment = publication.html_attachments.first
    attachment.govspeak_content.body = "Test [Contact:#{contact.id}]"
    attachment.govspeak_content.save
    publication.reload

    populator = ServiceListeners::AttachmentDependencyPopulator.new(publication)
    populator.populate!

    publication.reload
    assert publication.depended_upon_contacts.exists?(contact.id)
  end
end
