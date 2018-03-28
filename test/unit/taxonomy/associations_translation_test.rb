require 'test_helper'

class Taxonomy::AssociationsTranslationTest < ActiveSupport::TestCase
  test 'works for a detailed guide' do
    topic = create(:topic)
    publishing_api_has_expanded_links(
      content_id: topic.content_id,
      expanded_links:  {
        topic_taxonomy_taxons: [
          {
            content_id: 'taxon-for-test-topic-content-id'
          }
        ]
      }
    )

    stub_publishing_api_policies
    publishing_api_has_expanded_links(
      content_id: policy_1['content_id'],
      expanded_links:  {
        topic_taxonomy_taxons: [
          {
            content_id: 'taxon-for-test-policy-content-id'
          }
        ]
      }
    )

    publishing_api_has_expanded_links(
      content_id: policy_area_1['content_id'],
      expanded_links:  {
        topic_taxonomy_taxons: [
          {
            content_id: 'taxon-for-test-policy-area-content-id'
          }
        ]
      }
    )

    edition = build(
      :detailed_guide,
      topics: [topic],
      policy_content_ids: [policy_1['content_id']]
    )

    taxon_content_ids =
      Taxonomy::AssociationsTranslation
        .mapped_taxon_content_ids_for_edition(edition)

    assert_same_elements(
      taxon_content_ids,
      [
        'taxon-for-test-topic-content-id',
        'taxon-for-test-policy-content-id',
        'taxon-for-test-policy-area-content-id'
      ]
    )
  end

  test 'works for a statistics announcement' do
    # topic means policy area...
    topic = create(:topic)
    publishing_api_has_expanded_links(
      content_id: topic.content_id,
      expanded_links:  {
        topic_taxonomy_taxons: [
          {
            content_id: 'taxon-for-test-policy-area-content-id'
          }
        ]
      }
    )

    model = build(
      :statistics_announcement,
      topics: [topic]
    )

    presenter = PublishingApiPresenters.presenter_for(model)

    taxon_content_ids =
      Taxonomy::AssociationsTranslation
        .mapped_taxon_content_ids_for_links(presenter.links)

    assert_same_elements(
      taxon_content_ids,
      [
        'taxon-for-test-policy-area-content-id'
      ]
    )
  end
end
