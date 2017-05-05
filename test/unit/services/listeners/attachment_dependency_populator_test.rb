require "minitest/autorun"
require "mocha/setup"
require_relative "../../../../lib/govspeak/contacts_extractor"
require_relative "../../../../app/services/service_listeners/attachment_dependency_populator"

module ServiceListeners
  class AttachmentDependencyPopulatorTest < MiniTest::Test
    class TestAssociation
      attr_reader :collection
      def initialize
        @collection = []
      end

      def <<(value)
        collection << value
      end

      def exists?
        raise "stub me"
      end

      def to_a
        collection
      end
    end

    def subject(edition)
      AttachmentDependencyPopulator.new(edition)
    end

    def test_populate_ignores_editions_that_do_not_have_html_attachments
      edition = stub
      subject(edition).populate!
    end

    def test_populate_adds_any_contacts_in_attachments_to_the_edition
      attachments = [
        stub(govspeak_content_body: "[Contact:1]"),
        stub(govspeak_content_body: "booyah")
      ]
      edition = stub(html_attachments: attachments)
      edition.stubs(:depended_upon_contacts).returns(edition_contacts = TestAssociation.new)
      edition_contacts.stubs(:exists?).returns(false)

      Govspeak::ContactsExtractor.expects(:new).with("booyah").returns(stub(contacts: []))
      Govspeak::ContactsExtractor.expects(:new).with("[Contact:1]")
        .returns(stub(contacts: [contact = stub(id: 1)]))
      subject(edition).populate!

      assert_equal [contact], edition_contacts.to_a
    end

    def test_populate_adds_any_contacts_from_multiple_attachments_to_the_edition
      attachments = [
        stub(govspeak_content_body: "[Contact:1]"),
        stub(govspeak_content_body: "[Contact:2]")
      ]
      edition = stub(html_attachments: attachments)
      edition.stubs(:depended_upon_contacts).returns(edition_contacts = TestAssociation.new)
      edition_contacts.stubs(:exists?).returns(false)

      Govspeak::ContactsExtractor.expects(:new).with("[Contact:1]")
        .returns(stub(contacts: [contact_one = stub(id: 1)]))
      Govspeak::ContactsExtractor.expects(:new).with("[Contact:2]")
        .returns(stub(contacts: [contact_two = stub(id: 2)]))

      subject(edition).populate!

      assert_equal [contact_one, contact_two], edition_contacts.to_a
    end

    def test_populate_doesnt_add_existing_contacts
      attachments = [
        stub(govspeak_content_body: "[Contact:1]"),
      ]
      edition = stub(html_attachments: attachments)
      edition.stubs(:depended_upon_contacts).returns(edition_contacts = TestAssociation.new)
      edition_contacts.stubs(:exists?).with(1).returns(true)

      Govspeak::ContactsExtractor.expects(:new).with("[Contact:1]")
        .returns(stub(contacts: [stub(id: 1)]))

      subject(edition).populate!

      assert_equal [], edition_contacts.to_a
    end
  end
end
