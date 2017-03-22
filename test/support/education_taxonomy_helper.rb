module EducationTaxonomyHelper
  def root_taxon_content_id
    Taxonomy::EDUCATION_CONTENT_ID
  end

  def draft_taxon_content_ids
    Taxonomy::DRAFT_CONTENT_IDS
  end

  def parent_taxon_content_id
    "904cfd73-2707-47b8-8754-5765ec5a5b68"
  end

  def child_taxon_content_id
    "07fdd985-f3ec-4f4e-a316-3f4fd491bd64"
  end

  def grandparent_taxon_content_id
    "7c75c541-403f-4cb1-9b34-4ddde816a80d"
  end

  def stub_education_taxonomy_with_draft_expanded_links
    publishing_api_has_item({
      "title" => "Education",
      "base_path" => "/education",
      "content_id" => root_taxon_content_id
    })

    live_links = {
      content_id: root_taxon_content_id,
      expanded_links: {
        "child_taxons" => [
          grandparent_taxon
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

    publishing_api_has_expanded_links(live_links, with_drafts: false)
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
end
