require "test_helper"

class TopicListSelectPresenterTest < ActiveSupport::TestCase
  include TaxonomyHelper

  test ".grouped_options returns subtopics grouped by their parent topic" do
    stub_taxonomy_with_all_taxons
    #  this stubs a taxonomy with three taxons [Education, About your organisation, Parenting]
    # only Education and Parenting branches are taggable, so About your organisation is hidden
    #  from the select

    expected = [
      [
        "Education",
        [
          {
            text: "Education",
            value: root_taxon_content_id,
            selected: false,
          },
          {
            text: "Education > School Curriculum ",
            value: grandparent_taxon_content_id,
            selected: false,
          },
          {
            text: "Education > School Curriculum > Primary curriculum, key stage 1 ",
            value: parent_taxon_content_id,
            selected: false,
          },
          {
            text: "Education > School Curriculum > Primary curriculum, key stage 1 > Tests ",
            value: child_taxon_content_id,
            selected: false,
          },
        ],
      ],
      [
        "Parenting",
        [
          {
            text: "Parenting",
            value: draft_taxon_1_content_id,
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
