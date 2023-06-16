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
    assert_select "a[href=?]", reorder_admin_topical_event_topical_event_organisations_path(@topical_event), text: "Reorder organisations"
    refute_select "#supporting_organisations"
  end

  view_test "GET :index renders no reorder link when there is only one lead organisation" do
    create_list(:topical_event_organisation, 2, topical_event: @topical_event)
    lead_topical_event_organisations = create_list(:topical_event_organisation, 1, topical_event: @topical_event, lead: true)
    get :index, params: { topical_event_id: @topical_event }

    check_topical_event_organisations(lead_topical_event_organisations, "lead")
    refute_select "a[href=?]", reorder_admin_topical_event_topical_event_organisations_path(@topical_event), text: "Reorder organisations"
  end

  view_test "GET :index renders lead supporting organisations only with no reorder link" do
    supporting_topical_event_organisations = create_list(:topical_event_organisation, 2, topical_event: @topical_event)
    get :index, params: { topical_event_id: @topical_event }

    check_topical_event_organisations(supporting_topical_event_organisations, "supporting")
    refute_select "a[href=?]", reorder_admin_topical_event_topical_event_organisations_path(@topical_event)
    refute_select "#lead_organisations"
  end

  view_test "GET :index renders no organisations banner" do
    get :index, params: { topical_event_id: @topical_event }

    assert_template :index
    assert_response :success
    assert_select ".govuk-inset-text", "There are no organisations associated with this topical event."
  end

  view_test "GET :reorder renders reoderable list of lead organisations" do
    lead_topical_event_organisations = create_list(:topical_event_organisation, 2, topical_event: @topical_event, lead: true)
    get :reorder, params: { topical_event_id: @topical_event }

    assert_template :reorder
    assert_response :success
    assert_select "a[href=?]", admin_topical_event_topical_event_organisations_path(@topical_event), text: "Back"
    assert_select "h1", "Reorder lead organisations list"
    assert_select ".gem-c-reorderable-list", count: 1
    assert_select ".gem-c-reorderable-list__item", count: 2
    assert_select ".gem-c-reorderable-list__title", lead_topical_event_organisations[0].organisation.name
    assert_select ".gem-c-reorderable-list__title", lead_topical_event_organisations[1].organisation.name
  end

  test "PUT :order saves the new order of lead organisations" do
    lead_topical_event_organisations = create_list(:topical_event_organisation, 3, topical_event: @topical_event, lead: true)

    Whitehall::PublishingApi.expects(:republish_async).with(@topical_event).once

    put :order,
        params: { topical_event_id: @topical_event,
                  ordering: {
                    lead_topical_event_organisations[0].id.to_s => "1",
                    lead_topical_event_organisations[1].id.to_s => "2",
                    lead_topical_event_organisations[2].id.to_s => "0",
                  } }

    assert_response :redirect
    assert_equal [lead_topical_event_organisations[2], lead_topical_event_organisations[0], lead_topical_event_organisations[1]], @topical_event.reload.topical_event_organisations.where(lead: true).order(:lead_ordering)
  end

  test "GET :toggle_lead makes a supporting organisation into a lead with highest lead ordering" do
    create_list(:topical_event_organisation, 3, topical_event: @topical_event, lead: true)
    topical_event_organisation = create(:topical_event_organisation, topical_event: @topical_event, lead: false)

    Whitehall::PublishingApi.expects(:republish_async).with(@topical_event).once

    get :toggle_lead,
        params: { topical_event_id: @topical_event,
                  id: topical_event_organisation  }

    assert_response :redirect
    assert topical_event_organisation.reload.lead
    assert_equal 3, topical_event_organisation.lead_ordering
  end

  test "GET :toggle_lead makes a lead organisation into a supporting organisation" do
    topical_event_organisation = create(:topical_event_organisation, topical_event: @topical_event, lead: true)

    Whitehall::PublishingApi.expects(:republish_async).with(@topical_event).once

    get :toggle_lead,
        params: { topical_event_id: @topical_event,
                  id: topical_event_organisation  }

    assert_response :redirect
    assert_not topical_event_organisation.reload.lead
  end

  def check_topical_event_organisations(topical_event_organisations, type)
    assert_select "##{type}_organisations" do
      assert_select ".govuk-heading-s", "#{type.capitalize} organisations"
      topical_event_organisations.each do |topical_event_organisation|
        assert_select "th", topical_event_organisation.organisation.name
        assert_select "a[href=?]", admin_organisation_path(topical_event_organisation.organisation), text: "View #{topical_event_organisation.organisation.name}"
        assert_select "a[href=?]", toggle_lead_admin_topical_event_topical_event_organisation_path(@topical_event, topical_event_organisation), text: "Make #{type == 'lead' ? 'supporting' : 'lead'} #{topical_event_organisation.organisation.name}"
      end
    end
  end
end
