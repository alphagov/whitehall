require 'test_helper'

class Admin::DetailedGuidesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_creating_of :detailed_guide
  should_allow_editing_of :detailed_guide

  should_allow_organisations_for :detailed_guide
  should_allow_association_with_topics :detailed_guide
  should_require_alternative_format_provider_for :detailed_guide
  should_show_inline_attachment_help_for :detailed_guide
  should_allow_attached_images_for :detailed_guide
  should_prevent_modification_of_unmodifiable :detailed_guide
  should_allow_association_with_related_mainstream_content :detailed_guide
  should_allow_alternative_format_provider_for :detailed_guide
  should_allow_assignment_to_document_series :detailed_guide
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

  test "update allows removal of other mainstream categories" do
    funk = create(:mainstream_category, title: "Funk")
    soul = create(:mainstream_category, title: "Soul")
    existing_edition = create(:detailed_guide, primary_mainstream_category: funk, other_mainstream_categories: [soul])

    attributes = controller_attributes_for_instance(existing_edition)
    attributes.delete(:other_mainstream_category_ids)

    put :update,
      id: existing_edition,
      edition: attributes

    assert_equal [], existing_edition.reload.other_mainstream_categories
  end

  view_test "show displays association with mainstream categories" do
    funk = create(:mainstream_category, title: "Funk")
    soul = create(:mainstream_category, title: "Soul")

    detailed_guide = create(:detailed_guide, primary_mainstream_category: funk, other_mainstream_categories: [soul])

    get :show, id: detailed_guide

    assert_select '#associations' do
      assert_select 'a', funk.title
      assert_select 'a', soul.title
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:primary_mainstream_category, :alternative_format_provider).reverse_merge(
      primary_mainstream_category_id: create(:mainstream_category).id,
      alternative_format_provider_id: create(:alternative_format_provider).id
    )
  end
end
