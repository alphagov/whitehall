require "test_helper"

class ContentObjectStore::CopyableTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:document) { create(:content_block_document, :email_address) }
  let(:edition) { create(:content_block_edition, document:, state: "published") }

  it "creates a new edition given parameters" do
    # When I create a new edition
    organisation = create(:organisation)
    details = {
      "some" => "body",
    }
    title = "New title"

    params = {
      creator: create(:user).id,
      details:,
      document_attributes: {
        title:,
        block_type: "Something else",
      },
      organisation_id: organisation.id.to_s,
    }

    new_edition = edition.create_copy(edition_params: params)

    # Then a new edition should be created
    assert_equal document.editions.count, 2

    # And the title, details and organisation should be set on the new edition
    assert_equal new_edition.title, title
    assert_equal new_edition.details, details
    assert_equal new_edition.organisation, organisation

    # And the new edition should have a state of draft
    assert_equal new_edition.state, "draft"

    # And the new edition's document, block type and creator should remain the same
    assert_equal new_edition.document, document
    assert_equal new_edition.block_type, edition.block_type
    assert_equal new_edition.creator, edition.creator

    # And the document's latest_edition_id should have been updated
    assert_equal document.latest_edition_id, new_edition.id
  end

  it "throws an error if the params are invalid" do
    params = {}

    assert_raises ActiveRecord::RecordInvalid do
      edition.create_copy(edition_params: params)
    end
  end
end
