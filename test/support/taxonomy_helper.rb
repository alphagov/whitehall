module TaxonomyHelper
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

  def stub_taxonomy_with_all_taxons
    redis_cache_has_published_taxons [root_taxon]
    redis_cache_has_draft_taxons [draft_taxon_1, draft_taxon_2]
  end

  def redis_cache_has_published_taxons(taxons)
    redis_client
      .stubs(:get)
      .with(Taxonomy::RedisCacheAdapter::PUBLISHED_TAXONS_CACHE_KEY)
      .returns(JSON.dump(taxons))
  end

  def redis_cache_has_draft_taxons(taxons)
    redis_client
      .stubs(:get)
      .with(Taxonomy::RedisCacheAdapter::DRAFT_TAXONS_CACHE_KEY)
      .returns(JSON.dump(taxons))
  end

  def stub_govuk_taxonomy_matching_published_taxons(taxon_content_ids, matched_taxon_content_ids)
    Taxonomy::GovukTaxonomy
      .any_instance.stubs(:matching_against_published_taxons)
      .with(taxon_content_ids)
      .returns(matched_taxon_content_ids)
  end

  def stub_govuk_taxonomy_matching_visible_draft_taxons(taxon_content_ids, matched_taxon_content_ids)
    Taxonomy::GovukTaxonomy
      .any_instance.stubs(:matching_against_visible_draft_taxons)
      .with(taxon_content_ids)
      .returns(matched_taxon_content_ids)
  end

private

  def redis_client
    @_redis ||= Redis.current = stub
  end

  def child_taxon
    {
      "base_path" => "/education/primary-curriculum-key-stage-1-tests",
      "content_id" => child_taxon_content_id,
      "title" => "Tests",
      "links" => {}
    }
  end

  def parent_taxon
    {
      "base_path" => "/education/primary-curriculum-key-stage-1",
      "content_id" => parent_taxon_content_id,
      "title": "Primary curriculum, key stage 1",
      "links" => {
        "child_taxons" => [
          child_taxon
        ]
      }
    }
  end

  def grandparent_taxon
    {
      "base_path" => "/education/school-curriculum",
      "content_id" => grandparent_taxon_content_id,
      "title" => "School Curriculum",
      "links" => {
        "child_taxons" => [parent_taxon]
      }
    }
  end

  def root_taxon
    {
      "title" => "Education",
      "base_path" => "/education",
      "content_id" => root_taxon_content_id,
      "expanded_links_hash" => {
        "expanded_links" => {
          "child_taxons" => [grandparent_taxon]
        }
      }
    }
  end

  def draft_taxon_1
    {
      "title" => "About your organisation",
      "base_path" => "/about-your-organisation",
      "content_id" => draft_taxon_1_content_id,
      "expanded_links_hash" => {
        "expanded_links" => {
          "child_taxons" => []
        }
      }
    }
  end

  def draft_taxon_2
    {
      "title" => "Parenting",
      "base_path" => "/childcare-parenting",
      "content_id" => "draft_taxon_2",
      "expanded_links_hash" => {
        "expanded_links" => {
          "child_taxons" => []
        }
      }
    }
  end
end
