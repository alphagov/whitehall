require "test_helper"

class TopicListSelectPresenterTest < ActiveSupport::TestCase
  include TaxonomyHelper

  test ".grouped_options returns subtopics grouped by their parent topic" do
    stub_taxonomy_with_selected_taxons
    #  this stubs a taxonomy with two taxons [Education, Employment]
    #  only Employment is taggable, so Education is hidden from the select

    expected = [
      [
        "Employment",
        [
          {
            text: "Employment",
            value: employment_taxon_content_id,
            selected: false,
          },
          {
            text: "Employment > Employment is good ",
            value: employment_taxon_child_content_id,
            selected: false,
          },
          {
            text: "Employment > Employment is good > If you like your job ",
            value: employment_taxon_child_content_id,
            selected: false,
          },
          {
            text: "Employment > Employment is good > If you like your job > The end ",
            value: employment_taxon_child_content_id,
            selected: false,
          },
        ],
      ],
    ]

    document_collection = create(:draft_document_collection)

    result = TopicListSelectPresenter.new(document_collection).grouped_options
    assert_equal expected, result
  end
end
