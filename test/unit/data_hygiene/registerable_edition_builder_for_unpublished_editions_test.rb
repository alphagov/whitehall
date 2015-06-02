require "test_helper"
require "data_hygiene/registerable_edition_builder_for_unpublished_editions"

class RegisterableEditionBuilderForUnpublishedEditionsTest < ActiveSupport::TestCase
  setup do
    control_edition_1 = create(:published_edition)
    control_edition_2 = create(:draft_edition)
  end

  test "builds a set that includes editions that are unpublished and withdrawn" do
    withdrawn_edition = create(:edition, :unpublished, :withdrawn)

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(withdrawn_edition)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "archived", registerable_editions.last.state
  end

  test "builds a set that includes editions that are unpublished and deleted" do
    edition_to_delete = create(:unpublished_edition)
    edition_to_delete.delete!

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(edition_to_delete)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "archived", registerable_editions.last.state
  end

  test "builds a set that includes editions that have been republished" do
    unpublished_edition = create(:unpublished_edition)
    document = unpublished_edition.document

    unpublished_edition.delete!
    republished_edition = create(:published_edition, document: document)

    registerable_editions = RegisterableEditionBuilderForUnpublishedEditions.build
    expected_registerable_edition = RegisterableEdition.new(republished_edition)

    assert_equal [expected_registerable_edition], registerable_editions
    assert_equal "live", registerable_editions.last.state
  end
end
