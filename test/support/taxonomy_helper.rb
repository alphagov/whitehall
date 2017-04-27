module TaxonomyHelper
  def homepage_content_id
    Taxonomy::HOMEPAGE_CONTENT_ID
  end

  def root_taxon_content_id
    "a"
  end

  def draft_taxon_content_ids
    Taxonomy::DRAFT_CONTENT_IDS
  end

  def parent_taxon_content_id
    "d"
  end

  def child_taxon_content_id
    "e"
  end

  def grandparent_taxon_content_id
    "f"
  end

  def stub_taxonomy_with_draft_expanded_links
    homepage_links = {
      content_id: homepage_content_id,
      expanded_links: {
        "child_taxons" => [
          root_taxon
        ]
      }
    }

    publishing_api_has_item({
      "title" => "About your organisation",
      "base_path" => "/about-your-organisation",
      "content_id" => draft_taxon_content_ids.first
    })

    draft_taxon_1 = {
      content_id: draft_taxon_content_ids.first,
      expanded_links: {
        "child_taxons" => []
      }
    }

    publishing_api_has_item({
      "title" => "Parenting",
      "base_path" => "/childcare-parenting",
      "content_id" => draft_taxon_content_ids.last
    })

    draft_taxon_2 = {
      content_id: draft_taxon_content_ids.last,
      expanded_links: {
        "child_taxons" => []
      }
    }

    publishing_api_has_expanded_links(homepage_links, with_drafts: false)
    publishing_api_has_expanded_links(draft_taxon_1, with_drafts: true)
    publishing_api_has_expanded_links(draft_taxon_2, with_drafts: true)
  end

private

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
      "links" => {
        "child_taxons" => [grandparent_taxon]
      }
    }
  end
end
