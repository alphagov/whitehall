require 'test_helper'
require "gds_api/test_helpers/rummager"

class PeopleControllerTest < ActionController::TestCase
  include FeedHelper
  include GdsApi::TestHelpers::Rummager
  include GdsApi::TestHelpers::ContentStore

  should_be_a_public_facing_controller

  def stub_role_appointment(role_type, options = {})
    organisation = stub_translatable_record(:organisation, organisation_type: OrganisationType.ministerial_department)

    role_appointment_attributes = {
      role: stub_translatable_record(role_type, organisations: [organisation]),
      person: stub_translatable_record(:person, organisations: [organisation])
    }.merge(options)

    stub_record(:role_appointment, role_appointment_attributes)
  end

  setup do
    @person = create(:person)
    rummager_has_no_policies_for_any_type
    content_store_has_item(@person.search_link)
  end

  view_test "#show displays the details of the person and their roles" do
    first_appointment = create(:ministerial_role_appointment, person: @person)
    second_appointment = create(:ministerial_role_appointment, person: @person)
    get :show, params: { id: @person }

    assert_select "h1", text: @person.name
    assert_select ".biography", text: @person.biography

    assert_select ".current-roles" do
      assert_select_object first_appointment do
        assert_select "a[href=?]", ministerial_role_path(first_appointment.role)
      end
      assert_select_object second_appointment do
        assert_select "a[href=?]", ministerial_role_path(second_appointment.role)
      end
    end
  end

  view_test 'show has atom feed autodiscovery link' do
    get :show, params: { id: @person }
    assert_select_autodiscovery_link atom_feed_url_for(@person)
  end

  test "GET :show sets the slimmer header for the person's organisation" do
    role_appointment = create(:role_appointment, person: @person)
    organisation = role_appointment.organisations.first
    get :show, params: { id: @person }

    assert_equal "<#{organisation.analytics_identifier}>", response.headers["X-Slimmer-Organisations"]
  end

  test 'GET :show does not set the organisations slimmer header if the person is not associated with one' do
    get :show, params: { id: @person }

    assert_nil response.headers["X-Slimmer-Organisations"]
  end

  view_test "#show generates an atom feed of news and speeches associated with the person" do
    person = create(:person, slug: 'a-person')

    get :show, params: { id: person }, format: :atom

    assert_redirected_to '/government/announcements.atom?people[]=a-person'
  end

  view_test "should display the person's policies with content" do
    create(:ministerial_role_appointment, person: @person)
    rummager_has_policies_for_every_type

    get :show, params: { id: @person }

    assert_select "#policy" do
      assert_select "a[href='/government/policies/welfare-reform']", text: "Welfare reform"
    end
  end
end
