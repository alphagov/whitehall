module TaxonomyHelper
  def taxon(content_id, title)
    ::Taxonomy::Taxon.from_taxon_hash(
      build(:taxon_hash, content_id: content_id, title: title)
    )
  end

  def homepage_content_id
    Taxonomy::PublishingApiAdapter::HOMEPAGE_CONTENT_ID
  end

  def root_taxon_content_id
    "root"
  end

  def parent_taxon_content_id
    "parent"
  end

  def child_taxon_content_id
    "child"
  end

  def draft_taxon_1_content_id
    "draft_taxon_1"
  end

  def grandparent_taxon_content_id
    "grandparent"
  end

  def world_taxon_content_id
    "world"
  end

  def world_child_taxon_content_id
    "world_child"
  end

  def world_grandchild_taxon_content_id
    "world_grandchild"
  end

  def stub_taxonomy_with_all_taxons
    redis_cache_has_taxons [root_taxon, draft_taxon_1, draft_taxon_2]
  end

  def stub_taxonomy_with_world_taxons
    redis_cache_has_world_taxons([world_taxon])
  end

  def redis_cache_has_taxons(taxons)
    redis_client
      .stubs(:get)
      .with(Taxonomy::RedisCacheAdapter::TAXONS_CACHE_KEY)
      .returns(JSON.dump(taxons))
  end

  def redis_cache_has_world_taxons(world_taxons)
    redis_client
      .stubs(:get)
      .with(Taxonomy::RedisCacheAdapter::WORLD_TAXONS_CACHE_KEY)
      .returns(JSON.dump(world_taxons))
  end

  def stub_publishing_api_links_with_taxons(content_id, taxons)
    publishing_api_has_links(
      "content_id" => content_id,
      "links" => {
        "taxons" => taxons,
      },
      "version" => 1,
      )
  end

  def stub_publishing_api_expanded_links_with_taxons(content_id, taxons)
    publishing_api_has_expanded_links(
      "content_id" => content_id,
      "expanded_links" => {
        "taxons" => taxons,
      },
      "version" => 1,
      )
  end

  def rummager_can_find_document_with_taxon(search_link,
                                            taxon_ids,
                                            index_name = Whitehall::SearchIndex.government_search_index_path)
    store = Whitehall::SearchIndex.indexer_class.store
    unless store.is_a?(Whitehall::NotQuiteAsFakeSearch::Store)
      raise "Not a NotQuiteAsFakeSearch Datastore"
    end
    document = store.delete(search_link, index_name)
    store.add([document.merge(part_of_taxonomy_tree: taxon_ids)], index_name)
  end


private

  def redis_client
    @redis_client ||= Redis.current = stub
  end

  def child_taxon
    FactoryBot.build(:taxon_hash,
                     title: "Tests",
                     base_path: "/education/primary-curriculum-key-stage-1",
                     content_id: child_taxon_content_id,
                     is_level_one_taxon: false)
  end

  def parent_taxon
    FactoryBot.build(:taxon_hash,
                     title: "Primary curriculum, key stage 1",
                     base_path: "/education/primary-curriculum-key-stage-1",
                     content_id: parent_taxon_content_id,
                     is_level_one_taxon: false,
                     children: [child_taxon])
  end

  def grandparent_taxon
    FactoryBot.build(:taxon_hash,
                     title: "School Curriculum",
                     base_path: "/education/school-curriculum",
                     content_id: grandparent_taxon_content_id,
                     is_level_one_taxon: false,
                     children: [parent_taxon])
  end

  def root_taxon
    FactoryBot.build(:taxon_hash,
                     title: "Education",
                     base_path: "/education",
                     content_id: root_taxon_content_id,
                     children: [grandparent_taxon])
  end

  def draft_taxon_1
    FactoryBot.build(:taxon_hash,
                     title: "About your organisation",
                     base_path: "/about-your-organisation",
                     content_id: draft_taxon_1_content_id)
  end

  def draft_taxon_2
    FactoryBot.build(:taxon_hash,
                     title: "Parenting",
                     base_path: "/childcare-parenting",
                     content_id: draft_taxon_1_content_id)
  end

  def world_grandchild_taxon
    FactoryBot.build(:taxon_hash,
                     title: "World grandchild taxon",
                     base_path: "/world/grand-child",
                     content_id: world_grandchild_taxon_content_id,
                     is_level_one_taxon: false)
  end

  def world_child_taxon
    FactoryBot.build(:taxon_hash,
                     title: "World child taxon",
                     base_path: "/world/child",
                     content_id: world_child_taxon_content_id,
                     is_level_one_taxon: false,
                     children: [world_grandchild_taxon])
  end

  def world_taxon
    FactoryBot.build(:taxon_hash,
                     title: "World",
                     base_path: "/world/all",
                     content_id: world_taxon_content_id,
                     children: [world_child_taxon])
  end
end
