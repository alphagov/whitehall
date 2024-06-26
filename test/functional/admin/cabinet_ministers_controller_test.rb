require "test_helper"

class Admin::CabinetMinistersControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  def organisation
    @organisation ||= create(:organisation)
  end

  test "PATCH :order_cabinet_minister_roles should reorder ministerial roles and republish the ministers index page" do
    role2 = create(:ministerial_role, name: "Non-Executive Director", cabinet_member: true, organisations: [organisation])
    role1 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation])

    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)
    service.expects(:publish).with(PublishingApi::MinistersIndexPresenter)

    Sidekiq::Testing.inline! do
      patch :order_cabinet_minister_roles,
            params: {
              ministerial_roles: {
                ordering: {
                  role1.id.to_s => 0,
                  role2.id.to_s => 1,
                },
              },
            }
    end

    assert_equal MinisterialRole.cabinet.order(:seniority), [role1, role2]
    assert_redirected_to admin_cabinet_ministers_path(anchor: "cabinet_minister")
  end

  test "PATCH :order_also_attends_cabinet_roles should reorder people who also attend cabinet and republish the ministers index page" do
    role2 = create(:ministerial_role, name: "Chief Whip and Parliamentary Secretary to the Treasury", attends_cabinet_type_id: 2, organisations: [organisation])
    role1 = create(:ministerial_role, name: "Minister without Portfolio", attends_cabinet_type_id: 1, organisations: [organisation])

    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)
    service.expects(:publish).with(PublishingApi::MinistersIndexPresenter)

    Sidekiq::Testing.inline! do
      patch :order_also_attends_cabinet_roles,
            params: {
              ministerial_roles: {
                ordering: {
                  role1.id.to_s => 0,
                  role2.id.to_s => 1,
                },
              },
            }
    end

    assert_equal MinisterialRole.also_attends_cabinet.order(:seniority), [role1, role2]
    assert_redirected_to admin_cabinet_ministers_path(anchor: "also_attends_cabinet")
  end

  test "PATCH :order_whip_roles should reorder whips and republish the ministers index page" do
    role2 = create(:ministerial_role, name: "Whip 1", whip_organisation_id: 2, organisations: [organisation])
    role1 = create(:ministerial_role, name: "Whip 2", whip_organisation_id: 2, organisations: [organisation])

    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)
    service.expects(:publish).with(PublishingApi::MinistersIndexPresenter)

    Sidekiq::Testing.inline! do
      patch :order_whip_roles,
            params: {
              ministerial_roles: {
                ordering: {
                  role1.id.to_s => 0,
                  role2.id.to_s => 1,
                },
              },
            }
    end

    assert_equal MinisterialRole.whip.order(:seniority), [role2, role1]
    assert_equal MinisterialRole.whip.order(:whip_ordering), [role1, role2]
    assert_redirected_to admin_cabinet_ministers_path(anchor: "whips")
  end

  test "PATCH :order_ministerial_organisations should reorder ministerial organisations and republish the ministers index page" do
    org2 = create(:organisation)
    org1 = create(:organisation)

    service = mock
    PresentPageToPublishingApi.expects(:new).returns(service)
    service.expects(:publish).with(PublishingApi::MinistersIndexPresenter)

    Sidekiq::Testing.inline! do
      put :order_ministerial_organisations,
          params: {
            ministerial_organisations: {
              ordering: {
                org1.id.to_s => 0,
                org2.id.to_s => 1,
              },
            },
          }
    end

    assert_equal Organisation.order(:ministerial_ordering), [org1, org2]
    assert_redirected_to admin_cabinet_ministers_path(anchor: "organisations")
  end

  view_test "should list appointed cabinet ministers and ministerial organisations in separate tabs, in the correct order, with reorder links" do
    person = create(:person, forename: "Tony")
    minister1 = create(:ministerial_role, name: "Non-Executive Director", cabinet_member: true, organisations: [organisation], seniority: 1)
    minister2 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation], seniority: 0)
    # roles without a current appointment will not show in the list
    create(:role_appointment, role: minister1, person:)
    create(:role_appointment, role: minister2, person:)

    also_attends_cabinet1 = create(:ministerial_role, name: "Chief Whip and Parliamentary Secretary to the Treasury", attends_cabinet_type_id: 2, organisations: [organisation], seniority: 1)
    also_attends_cabinet2 = create(:ministerial_role, name: "Minister without Portfolio", attends_cabinet_type_id: 1, organisations: [organisation], seniority: 0)

    whip1 = create(:ministerial_role, name: "Whip 1", whip_organisation_id: 2, organisations: [organisation], whip_ordering: 1)
    whip2 = create(:ministerial_role, name: "Whip 2", whip_organisation_id: 2, organisations: [organisation], whip_ordering: 0)

    org1 = create(:ministerial_department, ministerial_ordering: 1)
    org2 = create(:ministerial_department, ministerial_ordering: 0)

    get :show

    assert_tab_has_href_and_ordered_roles("#cabinet_minister", reorder_cabinet_minister_roles_admin_cabinet_ministers_path, [minister2, minister1])
    assert_tab_has_href_and_ordered_roles("#also_attends_cabinet", reorder_also_attends_cabinet_roles_admin_cabinet_ministers_path, [also_attends_cabinet2, also_attends_cabinet1])
    assert_tab_has_href_and_ordered_roles("#whips", reorder_whip_roles_admin_cabinet_ministers_path, [whip2, whip1])
    assert_tab_has_href_and_ordered_roles("#organisations", reorder_ministerial_organisations_admin_cabinet_ministers_path, [org2, org1])
  end

  view_test "GET :reorder_cabinet_minister_roles should assign roles correctly and the cancel_path should have the correct anchor" do
    person = create(:person, forename: "Tony")
    minister1 = create(:ministerial_role, name: "Non-Executive Director", cabinet_member: true, organisations: [organisation], seniority: 1)
    minister2 = create(:ministerial_role, name: "Prime Minister", cabinet_member: true, organisations: [organisation], seniority: 0)
    create(:role_appointment, role: minister1, person:)
    create(:role_appointment, role: minister2, person:)

    get :reorder_cabinet_minister_roles

    assert_response :success
    assert_template "reorder_cabinet_minister_roles"
    assert_equal assigns(:roles), [minister2, minister1]
    assert_select ".govuk-link[href='#{admin_cabinet_ministers_path}#cabinet_minister']", text: "Cancel"
  end

  view_test "GET :reorder_also_attends_cabinet_roles should assign roles correctly and the cancel_path should have the correct anchor" do
    also_attends_cabinet1 = create(:ministerial_role, name: "Chief Whip and Parliamentary Secretary to the Treasury", attends_cabinet_type_id: 2, organisations: [organisation], seniority: 1)
    also_attends_cabinet2 = create(:ministerial_role, name: "Minister without Portfolio", attends_cabinet_type_id: 1, organisations: [organisation], seniority: 0)

    get :reorder_also_attends_cabinet_roles

    assert_response :success
    assert_template "reorder_also_attends_cabinet_roles"
    assert_equal assigns(:roles), [also_attends_cabinet2, also_attends_cabinet1]
    assert_select ".govuk-link[href='#{admin_cabinet_ministers_path}#also_attends_cabinet']", text: "Cancel"
  end

  view_test "GET :reorder_whip_roles should assign roles correctly and the cancel_path should have the correct anchor" do
    whip1 = create(:ministerial_role, name: "Whip 1", whip_organisation_id: 2, organisations: [organisation], whip_ordering: 1)
    whip2 = create(:ministerial_role, name: "Whip 2", whip_organisation_id: 2, organisations: [organisation], whip_ordering: 0)

    get :reorder_whip_roles

    assert_response :success
    assert_template "reorder_whip_roles"
    assert_equal assigns(:roles), [whip2, whip1]
    assert_select ".govuk-link[href='#{admin_cabinet_ministers_path}#whips']", text: "Cancel"
  end

  view_test "GET :reorder_ministerial_organisations should assign roles correctly and the cancel_path should have the correct anchor" do
    org1 = create(:ministerial_department, ministerial_ordering: 1)
    org2 = create(:ministerial_department, ministerial_ordering: 0)

    get :reorder_ministerial_organisations

    assert_response :success
    assert_template "reorder_ministerial_organisations"
    assert_equal assigns(:organisations), [org2, org1]
    assert_select ".govuk-link[href='#{admin_cabinet_ministers_path}#organisations']", text: "Cancel"
  end

private

  def assert_tab_has_href_and_ordered_roles(id, href, roles)
    assert_select id do
      assert_select ".govuk-link", text: "Reorder list" do |links|
        assert links.first[:href] == href
      end

      roles.each_with_index do |role, index|
        assert_select ".govuk-table__row:nth-child(#{index + 1}) td:first-child", role.name
      end
    end
  end
end
