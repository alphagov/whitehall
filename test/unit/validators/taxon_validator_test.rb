require 'test_helper'

class TaxonValidatorTest < ActiveSupport::TestCase
  setup do
    @validator = TaxonValidator.new
  end

  test 'is invalid when edition has not been tagged to a taxon' do
    edition = create(:draft_edition)
    edition.stubs(:can_be_tagged_to_taxonomy?).returns(true)

    publishing_api_has_links(
      "content_id" => edition.content_id,
      "links" => {
        "organisations" => ["569a9ee5-c195-4b7f-b9dc-edc17a09113f"],
      },
      "version" => 1
    )

    publishing_api_has_expanded_links(
      content_id:  edition.content_id,
      expanded_links:  {}
    )

    @validator.validate(edition)

    assert_equal 1, edition.errors.count
    assert_equal(
      "<b>This document has not been published.</b> You need to add a topic before publishing.",
      edition.errors[:base].first
    )
  end

  test 'is valid when edition has been tagged to a taxon' do
    edition = create(:draft_edition)
    edition.stubs(:can_be_tagged_to_taxonomy?).returns(true)

    publishing_api_has_links(
      "content_id" => edition.content_id,
      "links" => {
        "organisations" => ["569a9ee5-c195-4b7f-b9dc-edc17a09113f"],
        "taxons" => ["7754ae52-34aa-499e-a6dd-88f04633b8ab"]
      },
      "version" => 1
    )

    publishing_api_has_expanded_links(
      content_id:  edition.content_id,
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Primary Education",
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Education, Training and Skills",
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )

    @validator.validate(edition)
    assert_equal 0, edition.errors.count
  end
end
