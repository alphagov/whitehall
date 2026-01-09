require "test_helper"

module ServiceListeners
  class EditionDependenciesPopulatorTest < ActiveSupport::TestCase
    test "populates contacts extracted from dependent editions' govspeak" do
      contacts = create_list(:contact, 2)
      publication = create(
        :publication,
        body: "For more information, get in touch at:
      [Contact:#{contacts[0].id}] or [Contact:#{contacts[1].id}]",
      )

      EditionDependenciesPopulator.new(publication).populate!

      assert_same_elements contacts, publication.depended_upon_contacts.reload
    end

    test "populates editions extracted from dependent editions' govspeak" do
      speeches = create_list(:speech, 2)
      publication = create(
        :publication,
        body: "The Governor's speeches are available:
      - [London](/government/admin/speeches/#{speeches[0].id}), and
      - [Cambridge](/government/admin/speeches/#{speeches[1].id})",
      )

      EditionDependenciesPopulator.new(publication).populate!

      assert_same_elements speeches, publication.depended_upon_editions.reload
    end

    test "doesn't try to re-create an existing contact dependency" do
      contact = create(:contact)
      publication = create(:publication, body: "For more information, get in touch at: [Contact:#{contact.id}]")
      publication.depended_upon_contacts << contact # dependency is populated already

      EditionDependenciesPopulator.new(publication).populate!

      assert_same_elements [contact], publication.depended_upon_contacts.reload
    end

    test "doesn't try to re-create an existing edition dependency" do
      speech = create(:speech)
      publication = create(:publication, body: "Governor's new [speech](/government/admin/speeches/#{speech.id})")
      publication.depended_upon_editions << speech # dependency is populated already

      EditionDependenciesPopulator.new(publication).populate!

      assert_same_elements [speech], publication.depended_upon_editions.reload
    end
  end
end
