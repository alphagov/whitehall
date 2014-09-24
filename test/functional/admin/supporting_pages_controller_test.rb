require "test_helper"

class Admin::SupportingPagesControllerTest < ActionController::TestCase
  setup do
    login_as :policy_writer
  end

  should_be_an_admin_controller
  should_allow_attached_images_for :supporting_page
  should_allow_alternative_format_provider_for :supporting_page


  view_test "GET :new pre-selects the parent policy when provided" do
    policy = create(:policy)
    policy_2 = create(:policy)
    get :new, edition: { related_policy_ids: [policy.id] }

    assert_select "select#edition_related_policy_ids" do
      assert_select "option[selected='selected']", text: "#{policy.title} (#{policy.topics.first.name})"
    end
  end

  view_test "GET :edit pre-selects any parent policies" do
    policy = create(:policy)
    policy_2 = create(:policy)
    supporting_page = create(:supporting_page, related_policies: [policy])
    get :edit, id: supporting_page.id

    assert_select "select#edition_related_policy_ids" do
      assert_select "option[selected='selected']", text: "#{policy.title} (#{policy.topics.first.name})"
    end
  end

private
  def controller_attributes_for(edition_type, attributes = {})
    super.reverse_merge(
      related_policy_ids: [create(:policy).id]
    )
  end
end
