require 'test_helper'

class PublishingApiPresenters::DocumentCollectionPlaceholderTest < ActiveSupport::TestCase
  def present(model_instance, options = {})
    PublishingApiPresenters::DocumentCollectionPlaceholder.new(model_instance, options)
  end

  test 'presents a placeholder_document_collection ready for adding to the publishing API' do
    publications_in_collection = [
      create(:published_policy_paper, title: 'Free bunnies for all citizens'),
      create(:published_policy_paper, title: 'Photos of cats to be included in all HMRC letters')
    ]

    documents_in_collection = publications_in_collection.map(&:document)

    create(:published_policy_paper, title: 'Something about tax')

    document_collection = create(:published_document_collection,
      title: 'Things that make you go aww',
      summary: 'Things the government does that will make you happy',
      groups: [
        build(:document_collection_group, documents: documents_in_collection)
      ])

    public_path = Whitehall.url_maker.public_document_path(document_collection)

    expected_hash = {
      base_path: public_path,
      title: 'Things that make you go aww',
      description: 'Things the government does that will make you happy',
      format: 'placeholder_document_collection',
      locale: 'en',
      publishing_app: 'whitehall',
      rendering_app: 'whitehall-frontend',
      public_updated_at: document_collection.public_timestamp,
      routes: [{ path: public_path, type: 'exact' }],
      redirects: [],
      need_ids: [],
      details: {
        tags: {
          browse_pages: [],
          policies: [],
          topics: []
        }
      }
    }

    presented_item = present(document_collection)

    assert_equal expected_hash, presented_item.content
    assert_equal documents_in_collection.map(&:content_id).sort, presented_item.links[:documents].sort
    assert_equal 'major', presented_item.update_type
    assert_equal document_collection.content_id, presented_item.content_id

    assert_valid_against_schema(presented_item.content, 'placeholder')
  end
end
