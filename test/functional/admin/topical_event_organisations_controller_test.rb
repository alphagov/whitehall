require "test_helper"

class Admin::TopicalEventOrganisationsControllerTest < ActionController::TestCase
  should_be_an_admin_controller

  setup do
    @topical_event = create(:topical_event)
    login_as_preview_design_system_user :writer
  end

  view_test "GET :index renders headings and links" do
    get :index, params: { topical_event_id: @topical_event }

    assert_template :index
    assert_response :success
    assert_select "a[href=?]", admin_topical_events_path, text: "Back"
    assert_select "h1", @topical_event.name
    assert_select "a[href=?]", @topical_event.public_url({ cachebust: Time.zone.now.getutc.to_i }), text: "View on website"
    assert_select "a[href=?]", admin_topical_event_topical_event_organisations_path(@topical_event), text: "Organisations"
  end

  view_test "GET :index renders lead organisations only" do
    lead_topical_event_organisations = create_list(:topical_event_organisation, 2, topical_event: @topical_event, lead: true)
    get :index, params: { topical_event_id: @topical_event }

    check_topical_event_organisations(lead_topical_event_organisations, "lead")
    refute_select "#supporting_organisations"
  end

  view_test "GET :index renders lead supporting organisations only" do
    supporting_topical_event_organisations = create_list(:topical_event_organisation, 2, topical_event: @topical_event)
    get :index, params: { topical_event_id: @topical_event }

    check_topical_event_organisations(supporting_topical_event_organisations, "supporting")
    refute_select "#lead_organisations"
  end

  view_test "GET :index renders no organisations banner" do
    get :index, params: { topical_event_id: @topical_event }

    assert_template :index
    assert_response :success
    assert_select ".govuk-inset-text", "There are no organisations associated with this topical event."
  end

  def check_topical_event_organisations(topical_event_organisations, type)
    assert_select "##{type}_organisations" do
      assert_select ".govuk-heading-s", "#{type.capitalize} organisations"
      assert_select "a[href=?]", "reorder_link", text: "Reorder organisations #{type}"
      topical_event_organisations.each do |topical_event_organisation|
        assert_select "th", topical_event_organisation.organisation.name
        assert_select "a[href=?]", admin_organisation_path(topical_event_organisation.organisation), text: "View #{topical_event_organisation.organisation.name}"
        assert_select "a[href=?]", "make_link", text: "Make #{type == 'lead' ? 'supporting' : 'lead'} #{topical_event_organisation.organisation.name}"
      end
    end
  end
end
