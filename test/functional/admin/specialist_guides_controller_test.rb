require 'test_helper'

class Admin::SpecialistGuidesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller

  should_allow_showing_of :specialist_guide
  should_allow_creating_of :specialist_guide
  should_allow_editing_of :specialist_guide
  should_allow_revision_of :specialist_guide

  should_show_document_audit_trail_for :specialist_guide, :show
  should_show_document_audit_trail_for :specialist_guide, :edit

  should_allow_organisations_for :specialist_guide
  should_allow_association_with_topics :specialist_guide
  should_allow_attachments_for :specialist_guide
  should_require_alternative_format_provider_for :specialist_guide
  show_should_display_attachments_for :specialist_guide
  should_show_inline_attachment_help_for :specialist_guide
  should_allow_attached_images_for :specialist_guide
  should_be_rejectable :specialist_guide
  should_be_publishable :specialist_guide
  should_be_force_publishable :specialist_guide
  should_be_able_to_delete_an_edition :specialist_guide
  should_link_to_public_version_when_published :specialist_guide
  should_not_link_to_public_version_when_not_published :specialist_guide
  should_link_to_preview_version_when_not_published :specialist_guide
  should_prevent_modification_of_unmodifiable :specialist_guide
  should_allow_association_with_related_mainstream_content :specialist_guide
  should_allow_alternative_format_provider_for :specialist_guide

  test "new allows selection of mainstream categories" do
    funk = create(:mainstream_category,
      title: "Funk",
      identifier: "http://example.com/tags/funk.json",
      parent_title: "Musical style")

    get :new

    assert_select "form#edition_new[action='#{admin_specialist_guides_path}']" do
      assert_select "select[name='edition[primary_mainstream_category_id]']" do
        assert_select "optgroup[label='#{funk.parent_title}']" do
          assert_select "option[value='#{funk.id}']", funk.title
        end
      end
    end

    assert_select "form#edition_new[action='#{admin_specialist_guides_path}']" do
      assert_select "select[name='edition[other_mainstream_category_ids][]']" do
        assert_select "optgroup[label='#{funk.parent_title}']" do
          assert_select "option[value='#{funk.id}']", funk.title
        end
      end
    end
  end

  test "create records chosen primary mainstream category" do
    funk = create(:mainstream_category)

    attributes = controller_attributes_for(:specialist_guide, primary_mainstream_category_id: funk.id)

    post :create, edition: attributes

    assert_equal funk, SpecialistGuide.first.primary_mainstream_category
  end

  test "create records chosen other mainstream categories" do
    funk = create(:mainstream_category, title: "Funk")
    soul = create(:mainstream_category, title: "Soul")

    attributes = controller_attributes_for(:specialist_guide, primary_mainstream_category_id: funk.id,
                                           other_mainstream_category_ids: [soul.id])

    post :create, edition: attributes

    assert_equal [soul], SpecialistGuide.first.other_mainstream_categories
  end

  test "show displays association with mainstream categories" do
    funk = create(:mainstream_category, title: "Funk")
    soul = create(:mainstream_category, title: "Soul")

    specialist_guide = create(:specialist_guide, primary_mainstream_category: funk, other_mainstream_categories: [soul])

    get :show, id: specialist_guide

    assert_select '#associations' do
      assert_select 'a', funk.title
      assert_select 'a', soul.title
    end
  end

  private

  def controller_attributes_for(edition_type, attributes = {})
    super.except(:primary_mainstream_category).reverse_merge(primary_mainstream_category_id: create(:mainstream_category).id)
  end
end
