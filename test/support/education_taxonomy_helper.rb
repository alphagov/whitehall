module EducationTaxonomyHelper
  def stub_education_taxonomy
    education_content_id = Taxonomy::EDUCATION_CONTENT_ID
    @parent_taxon = "904cfd73-2707-47b8-8754-5765ec5a5b68"
    @child_taxon = "07fdd985-f3ec-4f4e-a316-3f4fd491bd64"

    publishing_api_has_item({
      "title" => "Education",
      "base_path" => "/education",
      "content_id" => education_content_id
    })
    key_stage_1 = {
      "base_path" => "/education/primary-curriculum-key-stage-1",
      "content_id" => @parent_taxon,
      "title": "Primary curriculum, key stage 1",
      "links" => {
        "child_taxons" => [
          {
            "base_path" => "/education/primary-curriculum-key-stage-1-tests",
            "content_id" => @child_taxon,
            "title" => "Tests",
            "links" => {}
          }
        ]
      }
    }

    publishing_api_has_expanded_links({
        content_id: education_content_id,
        expanded_links: {
          "child_taxons" => [
            {
              "base_path" => "/education/school-curriculum",
              "content_id" => "7c75c541-403f-4cb1-9b34-4ddde816a80d",
              "title" => "School Curriculum",
              "links" => {
                "child_taxons" => [key_stage_1]
              }
            }
          ]
        }
    })
  end
end
