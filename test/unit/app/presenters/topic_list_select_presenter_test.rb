require "test_helper"

class TopicListSelectPresenterTest < ActiveSupport::TestCase
  include TaxonomyHelper

  test ".grouped_options outputs what we are expecting" do
    stub_taxonomy_with_all_taxons

    expected = [
      [
        "Education",
        [
          {
            text: "School Curriculum",
            value: "grandparent",
            selected: false,
          },
        ],
      ],
      [
        "About your organisation", []
      ],
      [
        "Parenting", []
      ],
    ]

    document_collection = create(:draft_document_collection)

    result = TopicListSelectPresenter.new(document_collection).grouped_options
    assert_equal expected, result
  end
end
