module AdminTaxonomyHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def should_allow_tagging_to_taxonomy_for(model_type)
      view_test "when #{model_type} is not taggable hide taxonomy UI" do
        model = create(model_type)
        model_has_no_expanded_links(model.content_id)
        get :show, params: { id: model }
        refute_select '.taxonomy-topics'
      end

      view_test "when #{model_type} is taggable show the taxonomy UI" do
        organisation = create(:organisation, content_id: "ebd15ade-73b2-4eaf-b1c3-43034a42eb37")
        model = create(model_type, organisations: [organisation])
        login_as(create(:gds_editor, organisation: organisation))
        model_has_no_expanded_links(model.content_id)
        get :show, params: { id: model }
        assert_select '.taxonomy-topics .btn', "Add topic"
      end

      view_test "when #{model_type} is not tagged to the new taxonomy" do
        organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")
        model = create(model_type, organisations: [organisation])
        login_as(create(:gds_editor, organisation: organisation))
        model_has_no_expanded_links(model.content_id)
        get :show, params: { id: model }
        refute_select '.taxonomy-topics .content'
        assert_select '.taxonomy-topics .no-content', "No topics - please add a topic before publishing"
      end

      view_test "when #{model_type} is tagged to the new taxonomy" do
        organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")
        model = create(model_type, organisations: [organisation])
        login_as(create(:gds_editor, organisation: organisation))
        model_has_expanded_links(model.content_id)
        get :show, params: { id: model }
        refute_select '.taxonomy-topics .no-content'
        assert_select '.taxonomy-topics .content li', "Education, Training and Skills"
        assert_select '.taxonomy-topics .content li', "Primary Education"
      end
    end

    def should_prevent_legacy_tagging_for(model_type)
      view_test "when #{model_type} is not taggable show legacy UI" do
        get :new
        legacy_tag_fields_for(model_type).each { |field| assert_select field }
      end

      view_test "when #{model_type} is taggable hide legacy UI" do
        organisation = create(:organisation, content_id: "3e5a6924-b369-4eb3-8b06-3c0814701de4")
        login_as(create(:gds_editor, organisation: organisation))
        get :new
        legacy_tag_fields_for(model_type).each { |field| refute_select field }
      end
    end
  end

private

  def legacy_tag_fields_for(model_type)
    case model_type
    when :fatality_notice, :statistical_data_set
      %w{#edition_topic_ids #edition_primary_specialist_sector_tag}
    when :case_study
      %w{#edition_policy_content_ids #edition_primary_specialist_sector_tag}
    when :statistics_announcement
      %w{#statistics_announcement_topic_ids}
    else
      %w{#edition_topic_ids #edition_policy_content_ids #edition_primary_specialist_sector_tag}
    end
  end

  def model_has_no_expanded_links(content_id)
    publishing_api_has_expanded_links(
      content_id:  content_id,
      expanded_links:  {}
    )
  end

  def model_has_expanded_links(content_id)
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
