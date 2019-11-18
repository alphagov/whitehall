require "test_helper"
require "whitehall/internal_link_updater"

module Whitehall
  class InternalLinkUpdaterTest < ActiveSupport::TestCase
    test "relaces admin links in documents linking to the migrated document" do
      edition_linked_to = create(:edition_with_document, body: "Some document being migrated to Content Publisher")
      edition_linked_to.document.update(slug: "some-document", locked: true)
      edition_linked_from = create(:edition_with_document, body: "Text with a [link](/government/admin/news/#{edition_linked_to.id})")
      ServiceListeners::EditionDependenciesPopulator.new(edition_linked_from).populate!

      Whitehall::InternalLinkUpdater.new(edition_linked_to).call

      expected_body = "Text with a [link](www.test.gov.uk/government/generic-editions/some-document)"
      assert_equal edition_linked_from.reload.body, expected_body
    end

    test "does not replace admin links to other documents" do
      edition_linked_to_1 = create(:edition_with_document, body: "Some document being migrated to Content Publisher")
      edition_linked_to_1.document.update(slug: "some-document-1", locked: true)
      edition_linked_to_2 = create(:edition_with_document, body: "Some document not migrated to Content Publisher")
      edition_linked_to_2.document.update(slug: "some-document-2")
      edition_linked_from = create(:edition_with_document, body: "Text with a [link](/government/admin/news/#{edition_linked_to_1.id}) and another [link](/government/admin/news/#{edition_linked_to_2.id})")
      ServiceListeners::EditionDependenciesPopulator.new(edition_linked_from).populate!

      Whitehall::InternalLinkUpdater.new(edition_linked_to_1).call

      expected_body = "Text with a [link](www.test.gov.uk/government/generic-editions/some-document-1) and another [link](/government/admin/news/#{edition_linked_to_2.id})"
      assert_equal edition_linked_from.reload.body, expected_body
    end
  end
end
