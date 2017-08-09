require 'test_helper'

class Admin::CabinetMinistersControllerTest < ActionController::TestCase
  setup do
    login_as :gds_editor
  end

  should_be_an_admin_controller

  def organisation
    @organisation ||= create(:organisation)
  end

  test "should reorder ministerial roles" do
    role_2 = create(:ministerial_role, name: 'Non-Executive Director', cabinet_member: true, organisations: [organisation])
    role_1 = create(:ministerial_role, name: 'Prime Minister', cabinet_member: true, organisations: [organisation])

    put :update, params: {
      roles: {
        role_1.id.to_s => { ordering: 0 },
        role_2.id.to_s => { ordering: 1 },
      }
    }

    assert_equal MinisterialRole.cabinet.order(:seniority).to_a, [role_1, role_2]
  end

  test 'should reorder people who also attend cabinet' do
    role_2 = create(:ministerial_role, name: 'Chief Whip and Parliamentary Secretary to the Treasury', attends_cabinet_type_id: 2, organisations: [organisation])
    role_1 = create(:ministerial_role, name: 'Minister without Portfolio', attends_cabinet_type_id: 1, organisations: [organisation])

    put :update, params: {
      roles: {
        role_1.id.to_s => { ordering: 0 },
        role_2.id.to_s => { ordering: 1 },
      }
    }

    assert_equal MinisterialRole.also_attends_cabinet.order(:seniority).to_a, [role_1, role_2]
  end

  test 'should reorder whips as part of the same request' do
    role_2 = create(:ministerial_role, name: 'Whip 1', whip_organisation_id: 2, organisations: [organisation])
    role_1 = create(:ministerial_role, name: 'Whip 2', whip_organisation_id: 2, organisations: [organisation])

    put :update, params: {
      whips: {
        role_1.id.to_s => { ordering: 0 },
        role_2.id.to_s => { ordering: 1 },
      }
    }

    assert_equal MinisterialRole.whip.order(:seniority).to_a, [role_2, role_1]
    assert_equal MinisterialRole.whip.order(:whip_ordering).to_a, [role_1, role_2]
  end

  test 'should list ministerial organisations in ministerial order' do
    org_1 = create(:ministerial_department, ministerial_ordering: 0)
    org_2 = create(:ministerial_department, ministerial_ordering: 2)
    org_3 = create(:ministerial_department, ministerial_ordering: 1)

    get :show

    assert_equal assigns(:organisations).to_a, [org_1, org_3, org_2]
  end

  test 'should reorder ministerial organisations' do
    org_2 = create(:organisation)
    org_1 = create(:organisation)

    put :update, params: {
      organisation: {
        org_1.id.to_s => { ordering: 0 },
        org_2.id.to_s => { ordering: 1 },
      }
    }

    assert_equal Organisation.order(:ministerial_ordering), [org_1, org_2]
  end
end
