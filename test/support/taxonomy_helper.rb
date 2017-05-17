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

  def grandparent_taxon_content_id
    "grandparent"
  end

  def stub_taxonomy_with_draft_expanded_links
    homepage_links = {
      content_id: homepage_content_id,
      expanded_links: {
        "root_taxons" => [
          root_taxon
        ]
      }
    }

    publishing_api_has_expanded_links(homepage_links, with_drafts: false)
    publishing_api_has_expanded_links(root_taxon, with_drafts: true)

    homepage_links_with_drafts = {
      content_id: homepage_content_id,
      expanded_links: {
        "root_taxons" => [
          root_taxon,
          draft_taxon_1,
          draft_taxon_2
        ]
      }
    }

    publishing_api_has_expanded_links(homepage_links_with_drafts, with_drafts: true)
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
      "expanded_links" => {
        "child_taxons" => [grandparent_taxon]
      }
    }
  end

  def draft_taxon_1
    {
      "title" => "About your organisation",
      "base_path" => "/about-your-organisation",
      "content_id" => "draft_taxon_1",
      "expanded_links" => {
        "child_taxons" => []
      }
    }
  end

  def draft_taxon_2
    {
      "title" => "Parenting",
      "base_path" => "/childcare-parenting",
      "content_id" => "draft_taxon_2",
      "expanded_links" => {
        "child_taxons" => []
      }
    }
  end
end
