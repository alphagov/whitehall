require 'test_helper'
require 'gds_api/test_helpers/need_api'

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  include GdsApi::TestHelpers::NeedApi

  setup do
    login_as create(:policy_writer, organisation: create(:organisation))
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

  view_test "new allows selection of mainstream categories" do
    funk = create(:mainstream_category,
      title: "Funk",
      slug: "funk",
      parent_title: "Musical style",
      parent_tag: "music/70s")

    get :new

    assert_select "form#new_edition[action='#{admin_detailed_guides_path}']" do
      assert_select "select[name='edition[primary_mainstream_category_id]']" do
        assert_select "optgroup[label='#{funk.parent_title}']" do
          assert_select "option[value='#{funk.id}']", funk.title
        end
      end
    end

    assert_select "form#new_edition[action='#{admin_detailed_guides_path}']" do
      assert_select "select[name='edition[other_mainstream_category_ids][]']" do
        assert_select "optgroup[label='#{funk.parent_title}']" do
          assert_select "option[value='#{funk.id}']", funk.title
        end
      end
    end
  end

  test "associate user needs with a guide" do
    attributes = controller_attributes_for(:detailed_guide, need_ids: "123456, 789012")

    post :create, edition: attributes

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

    get :show, id: detailed_guide.id

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

  test "create records chosen primary mainstream category" do
    funk = create(:mainstream_category)

    attributes = controller_attributes_for(:detailed_guide, primary_mainstream_category_id: funk.id)

    post :create, edition: attributes

    assert_equal funk, DetailedGuide.first.primary_mainstream_category
  end

  test "create records chosen other mainstream categories" do
    funk = create(:mainstream_category, title: "Funk")
    soul = create(:mainstream_category, title: "Soul")

    attributes = controller_attributes_for(:detailed_guide, primary_mainstream_category_id: funk.id,
                                           other_mainstream_category_ids: [soul.id])

    post :create, edition: attributes

    assert_equal [soul], DetailedGuide.first.other_mainstream_categories
  end

  test "#create associates detailed guides to edition without stomping on other related documents" do
    policy        = create(:policy)
    related_guide = create(:published_detailed_guide)
    attributes    = controller_attributes_for(:detailed_guide,
                                              related_policy_ids: [policy.id],
                                              related_detailed_guide_ids: [related_guide.id])

    post :create, edition: attributes

    assert new_guide = DetailedGuide.last
    assert_same_elements [policy.document, related_guide.document], new_guide.related_documents
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:primary_mainstream_category, :alternative_format_provider).reverse_merge(
      primary_mainstream_category_id: create(:mainstream_category).id,
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
