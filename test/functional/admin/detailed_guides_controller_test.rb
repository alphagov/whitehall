require 'test_helper'
require 'gds_api/test_helpers/need_api'

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::NeedApi

  setup do
    login_as create(:writer, organisation: create(:organisation))
    create(:government)
  end

  should_be_an_admin_controller

  should_allow_creating_of :detailed_guide
  should_allow_editing_of :detailed_guide

  should_allow_organisations_for :detailed_guide
  should_allow_association_with_topics :detailed_guide
  should_allow_related_policies_for :detailed_guide
  should_allow_attached_images_for :detailed_guide
  should_prevent_modification_of_unmodifiable :detailed_guide
  should_allow_association_with_related_mainstream_content :detailed_guide
  should_allow_alternative_format_provider_for :detailed_guide
  should_allow_scheduled_publication_of :detailed_guide
  should_allow_overriding_of_first_published_at_for :detailed_guide
  should_allow_access_limiting_of :detailed_guide

  test "associate user needs with a guide" do
    attributes = controller_attributes_for(:detailed_guide, need_ids: "123456, 789012")

    post :create, params: { edition: attributes }

    assert_equal ["123456", "789012"], DetailedGuide.last.need_ids
  end

  view_test "user needs associated with a detailed guide" do
    need_api_has_need_ids([
      {
        "id" => "123456",
        "role" => "x",
        "goal" => "y",
        "benefit" => "z"
      },
      {
        "id" => "456789",
        "role" => "c",
        "goal" => "d",
        "benefit" => "e"
      }
    ])

    detailed_guide = create(:detailed_guide, need_ids: ["123456", "456789"])

    get :show, params: { id: detailed_guide.id }

    assert_select "#user-needs-section" do |section|
      assert_select "#user-need-id-123456" do
        assert_select ".description", text: "As a x,\n    I need to y,\n    So that z"
        assert_select ".maslow-url[href*='123456']"
      end

      assert_select "#user-need-id-456789" do
        assert_select ".description", text: "As a c,\n    I need to d,\n    So that e"
        assert_select ".maslow-url[href*='456789']"
      end
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:alternative_format_provider).reverse_merge(
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
