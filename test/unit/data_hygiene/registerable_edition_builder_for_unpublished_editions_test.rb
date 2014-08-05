require "test_helper"
require_relative "../../../lib/data_hygiene/registerable_edition_builder_for_unpublished_editions.rb"

class RegisterableEditionBuilderForUnpublishedEditionsTest < ActiveSupport::TestCase
  test "builds a set that includes editions that are unpublished and archived" do
    archived_edition = create(:edition, :unpublished, :archived)

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(archived_edition)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "archived", registerable_editions.last.state
  end

  test "builds a set that includes editions that are unpublished and deleted" do
    edition_to_delete = create(:edition, :unpublished)
    edition_to_delete.delete!

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(edition_to_delete)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "archived", registerable_editions.last.state
  end

  test "builds a set that includes editions that have been republished" do
    unpublished_edition = create(:edition, :unpublished)
    document = unpublished_edition.document

    unpublished_edition.delete!
    republished_edition = create(:edition, :published, document: document)

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(republished_edition)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "live", registerable_editions.last.state
  end
end
