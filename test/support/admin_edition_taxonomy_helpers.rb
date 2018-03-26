module AdminEditionTaxonomyHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_tagging_to_taxonomy_for(edition_type)
      view_test "when edition is not taggable hide taxonomy UI" do
        edition = create(edition_type)
        edition_has_no_expanded_links(edition.content_id)
        get :show, params: { id: edition }
        refute_select '.taxonomy-topics'
      end

      view_test "when edition is taggable show the taxonomy UI" do
        organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")
        edition = create(edition_type, organisations: [organisation])
        login_as(create(:user, organisation: organisation))
        edition_has_no_expanded_links(edition.content_id)
        get :show, params: { id: edition }
        assert_select '.taxonomy-topics .btn', "Add topic"
      end

      view_test "when edition is not tagged to the new taxonomy" do
        organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")
        edition = create(edition_type, organisations: [organisation])
        login_as(create(:user, organisation: organisation))
        edition_has_no_expanded_links(edition.content_id)
        get :show, params: { id: edition }
        refute_select '.taxonomy-topics .content'
        assert_select '.taxonomy-topics .no-content', "No topics - please add a topic before publishing"
      end

      view_test "when edition is tagged to the new taxonomy" do
        organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")
        edition = create(edition_type, organisations: [organisation])
        login_as(create(:user, organisation: organisation))
        edition_has_expanded_links(edition.content_id)
        get :show, params: { id: edition }
        refute_select '.taxonomy-topics .no-content'
        assert_select '.taxonomy-topics .content li', "Education, Training and Skills"
        assert_select '.taxonomy-topics .content li', "Primary Education"
      end
    end

    def should_prevent_legacy_tagging_for(edition_type)
      view_test "when edition is not taggable show legacy UI" do
        edition = create(edition_type)
        get :new
        assert_select '#edition_policy_content_ids'
        assert_select '#edition_topic_ids'
        assert_select '#edition_primary_specialist_sector_tag'
      end

      view_test "when edition is taggable hide legacy UI" do
        organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")
        edition = create(edition_type, organisations: [organisation])
        login_as(create(:user, organisation: organisation))
        get :new
        refute_select '#edition_policy_content_ids'
        refute_select '#edition_topic_ids'
        refute_select '#edition_primary_specialist_sector_tag'
      end
    end
  end

private

  def edition_has_no_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id:  content_id,
      expanded_links:  {}
    )
  end

  def edition_has_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id:  content_id,
      expanded_links:  {
        "taxons" => [
          {
            "title" => "Primary Education",
            "content_id" => "aaaa",
            "base_path" => "i-am-a-taxon",
            "details" => { "visible_to_departmental_editors" => true },
            "links" => {
              "parent_taxons" => [
                {
                  "title" => "Education, Training and Skills",
                  "content_id" => "bbbb",
                  "base_path" => "i-am-a-parent-taxon",
                  "details" => { "visible_to_departmental_editors" => true },
                  "links" => {}
                }
              ]
            }
          }
        ]
      }
    )
  end
end
